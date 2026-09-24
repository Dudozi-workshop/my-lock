import math
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
import vtk

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "shapes" / "dolphin"
OUT = ROOT / "assets" / "shapes" / "dolphin_baked"
OUT.mkdir(parents=True, exist_ok=True)

FRAME = 256
FRAMES = 24
GRID = 192

body_a = np.array(Image.open(SRC / "dolphin_body.png").convert("RGBA"))[:, :, 3]
belly_a = np.array(Image.open(SRC / "dolphin_belly_accent.png").convert("RGBA"))[:, :, 3]
mouth_a = np.array(Image.open(SRC / "dolphin_mouth_accent.png").convert("RGBA"))[:, :, 3]

ys, xs = np.where(body_a > 12)
minx, maxx = xs.min(), xs.max()
miny, maxy = ys.min(), ys.max()
pad = 20
minx = max(0, minx - pad)
maxx = min(511, maxx + pad)
miny = max(0, miny - pad)
maxy = min(511, maxy + pad)


def crop_resize(alpha):
    crop = alpha[miny : maxy + 1, minx : maxx + 1]
    return cv2.resize(crop, (GRID, GRID), interpolation=cv2.INTER_AREA)


body = crop_resize(body_a)
belly = crop_resize(belly_a)
mouth = crop_resize(mouth_a)

mask_blur = cv2.GaussianBlur(body, (0, 0), 1.15)
inside = (mask_blur > 18).astype(np.uint8)
dist = cv2.distanceTransform(inside, cv2.DIST_L2, 5)
if dist.max() > 0:
    dist /= dist.max()

height = (dist**0.62) * 0.62
height = cv2.GaussianBlur(height, (0, 0), 1.0)

xcoords = np.linspace(-2.0, 2.0, GRID)
ycoords = np.linspace(1.55, -1.55, GRID)


def deform_xy(x, y, phase):
    tail = np.clip((-1.05 - x) / 0.95, 0, 1)
    tail = tail * tail * (3 - 2 * tail)

    y2 = y + tail * 0.13 * math.sin(phase)
    x2 = x + tail * 0.025 * math.cos(phase)

    fin_zone = np.exp(-((x + 0.10) / 0.55) ** 2 - ((y + 0.65) / 0.28) ** 2)
    y2 += fin_zone * 0.035 * math.sin(phase + 0.8)
    return x2, y2


def build_surface(alpha_mask, phase, accent=False):
    active = (alpha_mask > 20) & (inside > 0)

    points = vtk.vtkPoints()
    vertex_ids = -np.ones((GRID, GRID), dtype=np.int32)

    for j in range(GRID):
        for i in range(GRID):
            if not active[j, i]:
                continue

            x = float(xcoords[i])
            y = float(ycoords[j])
            x, y = deform_xy(x, y, phase)
            z = float(height[j, i])
            if accent:
                z += 0.012

            vertex_ids[j, i] = points.InsertNextPoint(x, y, z)

    polys = vtk.vtkCellArray()
    for j in range(GRID - 1):
        for i in range(GRID - 1):
            ids = [
                vertex_ids[j, i],
                vertex_ids[j, i + 1],
                vertex_ids[j + 1, i + 1],
                vertex_ids[j + 1, i],
            ]
            if min(ids) < 0:
                continue

            quad = vtk.vtkQuad()
            for k, index in enumerate(ids):
                quad.GetPointIds().SetId(k, int(index))
            polys.InsertNextCell(quad)

    polydata = vtk.vtkPolyData()
    polydata.SetPoints(points)
    polydata.SetPolys(polys)

    normals = vtk.vtkPolyDataNormals()
    normals.SetInputData(polydata)
    normals.ComputePointNormalsOn()
    normals.ComputeCellNormalsOff()
    normals.SplittingOff()
    normals.ConsistencyOn()
    normals.AutoOrientNormalsOn()
    normals.SetFeatureAngle(180)
    normals.Update()
    return normals.GetOutput()


def actor_from_polydata(polydata, color, specular, specular_power, ambient, diffuse):
    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputData(polydata)

    actor = vtk.vtkActor()
    actor.SetMapper(mapper)

    prop = actor.GetProperty()
    prop.SetColor(*color)
    prop.SetSpecular(specular)
    prop.SetSpecularPower(specular_power)
    prop.SetAmbient(ambient)
    prop.SetDiffuse(diffuse)
    prop.SetInterpolationToPhong()
    return actor


def render(actors, path, phase):
    renderer = vtk.vtkRenderer()
    renderer.SetBackground(0, 0, 0)
    renderer.SetBackgroundAlpha(0)

    window = vtk.vtkRenderWindow()
    window.SetOffScreenRendering(1)
    window.SetAlphaBitPlanes(1)
    window.SetMultiSamples(8)
    window.SetSize(FRAME, FRAME)
    window.AddRenderer(renderer)

    for actor in actors:
        renderer.AddActor(actor)

    light_x = 3.2 + 0.35 * math.sin(phase)
    light_y = 4.4 + 0.18 * math.cos(phase)
    lights = [
        ((light_x, light_y, 6.4), 1.08, (1.0, 0.98, 0.96)),
        ((-4.0, 1.4, 4.2), 0.38, (0.70, 0.88, 1.0)),
        ((-2.2, -4.0, 3.0), 0.28, (0.55, 0.72, 1.0)),
    ]

    for position, intensity, color in lights:
        light = vtk.vtkLight()
        light.SetLightTypeToSceneLight()
        light.SetPosition(*position)
        light.SetFocalPoint(0, 0, 0)
        light.SetIntensity(intensity)
        light.SetColor(*color)
        renderer.AddLight(light)

    camera = renderer.GetActiveCamera()
    camera.ParallelProjectionOn()
    camera.SetParallelScale(1.95)
    camera.SetPosition(0.10, 0.05, 6.8)
    camera.SetFocalPoint(0, 0, 0.20)
    camera.SetViewUp(0, 1, 0)

    angle_y = 1.6 * math.sin(phase)
    angle_z = 1.1 * math.sin(phase * 0.5)
    for actor in actors:
        actor.RotateY(angle_y)
        actor.RotateZ(angle_z)

    window.Render()

    capture = vtk.vtkWindowToImageFilter()
    capture.SetInput(window)
    capture.SetInputBufferTypeToRGBA()
    capture.ReadFrontBufferOff()
    capture.Update()

    writer = vtk.vtkPNGWriter()
    writer.SetFileName(str(path))
    writer.SetInputConnection(capture.GetOutputPort())
    writer.Write()


def clean_alpha(path):
    image = Image.open(path).convert("RGBA")
    rgba = np.array(image)
    rgb = rgba[:, :, :3]

    black_background = rgb.max(axis=2) < 3
    rgba[black_background, 3] = 0
    Image.fromarray(rgba).save(path)


for frame in range(FRAMES):
    phase = 2 * math.pi * frame / FRAMES

    body_polydata = build_surface(body, phase)
    body_actor = actor_from_polydata(
        body_polydata,
        (0.78, 0.78, 0.78),
        specular=1.0,
        specular_power=110,
        ambient=0.12,
        diffuse=0.88,
    )
    body_path = OUT / f"body_{frame:02d}.png"
    render([body_actor], body_path, phase)
    clean_alpha(body_path)

    belly_polydata = build_surface(belly, phase, accent=True)
    mouth_polydata = build_surface(mouth, phase, accent=True)
    belly_actor = actor_from_polydata(
        belly_polydata,
        (0.98, 0.99, 1.0),
        specular=0.62,
        specular_power=55,
        ambient=0.20,
        diffuse=0.82,
    )
    mouth_actor = actor_from_polydata(
        mouth_polydata,
        (0.98, 0.99, 1.0),
        specular=0.62,
        specular_power=55,
        ambient=0.20,
        diffuse=0.82,
    )
    accent_path = OUT / f"accent_{frame:02d}.png"
    render([belly_actor, mouth_actor], accent_path, phase)
    clean_alpha(accent_path)

cols, rows = 6, 4
for prefix in ("body", "accent"):
    atlas = Image.new("RGBA", (cols * FRAME, rows * FRAME), (0, 0, 0, 0))
    for frame in range(FRAMES):
        image = Image.open(OUT / f"{prefix}_{frame:02d}.png").convert("RGBA")
        atlas.alpha_composite(
            image,
            ((frame % cols) * FRAME, (frame // cols) * FRAME),
        )
    atlas.save(OUT / f"dolphin_{prefix}_atlas_24.png", optimize=True)

for prefix in ("body", "accent"):
    for frame in range(FRAMES):
        (OUT / f"{prefix}_{frame:02d}.png").unlink(missing_ok=True)

print(f"Generated baked dolphin atlases in {OUT}")

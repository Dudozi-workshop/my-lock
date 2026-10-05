"""Deterministic Floor Caustic STATIC study, not a production/runtime asset.

Run with --base approved PNG --output directory. Requires numpy and Pillow.
Creates independent RGBA effect and QA composites without changing source.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


def smooth(a, b, v):
    t = np.clip((v-a)/(b-a), 0, 1)
    return t*t*(3-2*t)


def render(base_path, output):
    expected = '0bbc263d61b3a524b9c027e1894fab3209085d631c7a2c313d261a17ecf98ff2'
    assert hashlib.sha256(base_path.read_bytes()).hexdigest() == expected
    base = Image.open(base_path).convert('RGBA')
    w, h = base.size
    yy, xx = np.mgrid[:h, :w].astype(np.float32)
    x, y = xx/w, yy/h
    depth = np.maximum(y-.65, 0)
    # Project a plane: foreground cells grow and flatten toward the horizon.
    u = (x-.5)*3.8/(.22+depth*2.5)
    v = -4.2/(.22+depth*2.5)
    # Nonuniform domain bend avoids straight polygon edges and repeated grids.
    a = u+.20*np.sin(v*2.7+u*1.8)+.11*np.sin(v*5.1-u*2.3)
    b = v+.18*np.sin(u*2.1-v*1.7)+.09*np.sin(u*4.4+v*3.2)
    rng = np.random.default_rng(10504)
    d1 = np.full((h,w), 1e6, np.float32)
    d2 = d1.copy()
    for row in np.arange(-21, -2, .88):
        for col in np.arange(-10, 11, .92):
            # Large offsets deliberately break even cell spacing.
            sx, sy = col+rng.uniform(-.40,.40), row+rng.uniform(-.38,.38)
            dist = np.sqrt((a-sx)**2+(b-sy)**2)
            nearer = dist < d1
            d2 = np.where(nearer, d1, np.minimum(d2,dist))
            d1 = np.minimum(d1, dist)
    edge = d2-d1
    width = .061+.022*np.sin(a*2.2+b*1.9)
    core = np.exp(-(edge/width)**2)
    halo = np.exp(-(edge/(width*3.0))**2)
    intensity = .64+.22*np.sin(a*1.4-b*2.1)+.12*np.sin(b*4.2+a*.7)
    # Shape-aware static QA mask: keep rays off rocks, coral and shell.
    # Not a reusable production occlusion mask; viewport mapping must be reviewed.
    left = np.interp(y, [.65,.71,.77,.83,.89,.95,1], [.23,.27,.40,.47,.50,.45,.38])
    right = np.interp(y, [.65,.71,.77,.83,.89,.95,1], [.84,.85,.78,.88,.94,.99,1.02])
    mask = smooth(.655,.725,y)*smooth(left,left+.055,x)*(1-smooth(right-.04,right,x))
    opacity = np.clip((core*.69+halo*.13)*intensity*mask,0,.8)
    rgba = np.zeros((h,w,4), np.uint8)
    rgba[:,:,:3] = [255,247,211]
    rgba[:,:,3] = np.rint(opacity*255).astype(np.uint8)
    layer = Image.fromarray(rgba)
    composite = Image.alpha_composite(base, layer)
    output.mkdir(parents=True,exist_ok=True)
    layer.save(output/'floor_caustic_static_v1.png')
    composite.save(output/'floor_caustic_base_preview_v1.png')
    # Checker is for transparent layer visibility, never baked into effect.
    checker = ((xx//28+yy//28)%2)*10+30
    bg = np.empty((h,w,4),np.uint8)
    bg[:,:,:3] = checker[:,:,None]
    bg[:,:,3] = 255
    isolated = Image.alpha_composite(Image.fromarray(bg),layer)
    tile_w, tile_h = 420, round(h*420/w)
    sheet = Image.new('RGB',(tile_w*2+36,tile_h+92),'#102b40')
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',20)
    small = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
    draw.text((12,12),'FLOOR CAUSTIC / STATIC STUDY v1',fill='#eafaff',font=font)
    draw.text((12,43),'ISOLATED RGBA',fill='#b9d5e5',font=small)
    draw.text((tile_w+24,43),'APPROVED BASE + FLOOR',fill='#b9d5e5',font=small)
    sheet.paste(isolated.resize((tile_w,tile_h),Image.Resampling.LANCZOS),(12,68))
    sheet.paste(composite.resize((tile_w,tile_h),Image.Resampling.LANCZOS),(tile_w+24,68))
    sheet.save(output/'floor_caustic_review_v1.jpg',quality=94)
    alpha = rgba[:,:,3]
    assert not alpha[:int(h*.655)].any()
    assert hashlib.sha256(base_path.read_bytes()).hexdigest()==expected
    metadata = dict(status='static_art_direction_candidate_not_approved',
        scope='floor_only', imagegen=False, base_sha256=expected, width=w,height=h,
        seed=10504, motion_implemented=False, labs_changed=False,
        occlusion='approximate static preview mask; runtime viewport review required',
        alpha_max=int(alpha.max()),
        changed_pixels_above_floor=int(np.count_nonzero(np.asarray(base)[:int(h*.655)]!=np.asarray(composite)[:int(h*.655)])),
        files={p.name:dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in output.glob('*') if p.suffix in ('.png','.jpg')})
    (output/'floor_caustic_static_v1.json').write_text(json.dumps(metadata,indent=2)+'\n')
    print(json.dumps(metadata))


if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--base',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    render(args.base,args.output)

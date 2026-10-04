"""Deterministic Candy Soft runtime derivation; never redraw the approved atlas."""
import base64
import hashlib
import json
from pathlib import Path
import sys
import numpy as np
from PIL import Image
from scipy.ndimage import label, binary_dilation

source = Path(sys.argv[1])
assert hashlib.sha256(source.read_bytes()).hexdigest() == 'f32b0ef21c5aa16e4329ec966eaf5cd435947afb7334ee928f9421af837ca3c2'
atlas = Image.open(source).convert('RGBA')
root = Path(__file__).resolve().parents[1] / 'assets/raster_shapes/candy_soft_r2'
root.mkdir(parents=True, exist_ok=True)
records = []
for i, (shape, tone) in enumerate([('circle','pink'),('triangle','yellow'),('square','blue')]):
    slot = atlas.crop((724*i, 0, 724*(i+1), 724))
    pixels = np.array(slot)
    alpha = pixels[:,:,3]
    components, _ = label(alpha >= 16)
    sizes = np.bincount(components.ravel()); sizes[0] = 0
    body = components == sizes.argmax()
    # Preserve the antialiased edge surrounding the principal connected body;
    # remove only disconnected peripheral specks, never invent silhouette pixels.
    keep = binary_dilation(body, iterations=2)
    pixels[:,:,3] = np.where(keep, alpha, 0)
    clean = Image.fromarray(pixels)
    bbox = clean.getbbox()
    cropped = clean.crop(bbox)
    scale = 216 / max(cropped.size)
    size = tuple(round(v*scale) for v in cropped.size)
    reduced = cropped.resize(size, Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA', (256,256))
    offset = ((256-size[0])//2, (256-size[1])//2)
    canvas.paste(reduced, offset)
    p = np.array(canvas)
    rgb = p[:,:,:3].astype(np.int16)
    high = rgb.max(axis=2); low = rgb.min(axis=2)
    # C*hue + M: chroma drives selected hue; common-channel light preserves
    # white specular finish, black shade and original alpha in one shared source.
    field = p.copy(); field[:,:,0] = high-low; field[:,:,1] = low; field[:,:,2] = 0
    assets = {}
    for name, image in [('authored', canvas), ('field', Image.fromarray(field))]:
        import io
        stream = io.BytesIO(); image.save(stream, format='PNG', optimize=True)
        raw = stream.getvalue()
        filename = f'{shape}_{name}_256.b64'
        (root / filename).write_text(base64.b64encode(raw).decode()+'\n')
        assets[name] = {'asset':str((root/filename).relative_to(root.parents[2])), 'sha256':hashlib.sha256(raw).hexdigest()}
    records.append({'shape':shape,'authored_tone':tone,'source_rect':[724*i,0,724,724], 'clean_bbox':bbox,'runtime_canvas':[256,256],'anchor':[128,128],'padding_px':20,'content_bbox':canvas.getbbox(),'assets':assets,'removed_alpha_pixels':int(((alpha>0)&~keep).sum())})
    canvas.save(root/f'{shape}_preview.png')
(root/'manifest.json').write_text(json.dumps({'version':2,'status':'qa_candidate','user_direction_approved':True,'production_approved':False,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'palette_mode':'chroma_times_selected_hue_plus_common_channel_finish','shapes':records}, indent=2)+'\n')
print(json.dumps(records, indent=2))

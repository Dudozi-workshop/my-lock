"""Runtime-only optical factorization; never infer/change semantic ownership.
Input is the hash-verified approved Whole Assembly. Pillow + numpy required.
The optical finish stores every authored luminance sample (outline, shadow,
highlight and detail), independently of palette. This is not a replacement
for the locked canonical semantic Material masks/assets.
"""
import argparse, base64, hashlib, json
from pathlib import Path
import numpy as np
from PIL import Image

EXPECTED = '73f3e583d99d1e9405f54a44862c8c55dda49c464eccd5b73e529b8fab309e4c'
ROOT = Path(__file__).resolve().parents[1]

def sha(data): return hashlib.sha256(data).hexdigest()

def derive(source, output):
    raw = source.read_bytes()
    assert sha(raw) == EXPECTED, 'Canonical Whole Assembly hash mismatch'
    im = Image.open(source)
    assert im.mode == 'RGBA' and im.size == (2048, 2048)
    bbox = im.getchannel('A').getbbox()
    assert bbox == (420, 688, 1640, 1460)
    # 192px whole content within a 256px canvas, with 32px nominal padding.
    crop = (420, 464, 1640, 1684)
    content = im.crop(crop).resize((192, 192), Image.Resampling.LANCZOS)
    master = Image.new('RGBA', (256, 256))
    master.paste(content, (32, 32))
    px = np.array(master)
    px[px[:,:,3] == 0] = 0
    master = Image.fromarray(px)
    a = px[:,:,3]
    support = a > 0
    # Optical albedo and achromatic finish. The original source-pixel material
    # masks are untouched. Black/white optical density preserves ALL authored
    # luminance variation without green chroma bleeding into other palettes.
    y = np.dot(px[:,:,:3] / 255., [0.2126, 0.7152, 0.0722])
    reference = 0.70
    beta = np.where(y < reference, 1-y/reference, (y-reference)/(1-reference))
    finish = np.zeros_like(px)
    finish[:,:,:3] = np.where((y >= reference)[:,:,None], 255, 0)
    finish[:,:,3] = np.where(support, np.rint(beta*255), 0).astype('uint8')
    finish[~support] = 0
    # Palette support is opaque; apply true master alpha exactly ONCE after
    # both optical layers. Avoid double-alpha / edge opacity accumulation.
    base = np.zeros_like(px); base[support] = [255,255,255,255]
    output.mkdir(parents=True, exist_ok=True)
    layers = {}
    for name, img in [('master',master),('palette_base',Image.fromarray(base)),('fixed_finish',Image.fromarray(finish))]:
        path = output / f'sea_turtle_v3_{name}_256_v3.webp'
        img.save(path, 'WEBP', lossless=True, exact=True, method=6)
        assert np.array_equal(np.array(Image.open(path)),np.array(img))
        layers[name] = {'asset':str(path.relative_to(ROOT)), 'sha256':sha(path.read_bytes())}
    b = list(master.getchannel('A').getbbox())
    reconstructed = reference*(1-finish[:,:,3]/255.) + (finish[:,:,0]/255.)*(finish[:,:,3]/255.)
    error = float(np.max(np.abs(reconstructed[support]-y[support])))
    assert error < 1/255
    assert all(int(x)==0 for x in [a[0].max(),a[-1].max(),a[:,0].max(),a[:,-1].max()])
    meta = {'shape_id':'sea_turtle_v3','version':3,'status':'QA Candidate / user approval pending',
      'runtime_canvas':[256,256],'content_bbox':b,'anchor':[(b[0]+b[2])/2,(b[1]+b[3])/2],
      'display_scale':1.0,'safety_padding_ratio':min(b[0],b[1],256-b[2],256-b[3])/256,
      'runtime_source_hash':layers['master']['sha256'],'canonical_source_hash':EXPECTED,
      'source_crop':list(crop),'layers':layers,
      'material_model':'runtime optical albedo + fixed achromatic finish; locked semantic ownership unchanged',
      'reference_albedo_luminance':reference,
      'aurora':{'period_seconds':8,'palette':['#79BFFF','#FF8FD1','#FFDA72','#B7A4DF'], 'saturation_scale':0.55,'hue_field':'moving periodic 2D local gradient'},
      'qa':{'canvas_edge_alpha_pixels':0,'transparent_rgb_residue_pixels':0,
         'lossless_decode_equality':True,'reference_luminance_max_error':error,
         'geometry_material_ownership_changed':False,'imagegen_used':False}}
    (output/'sea_turtle_v3_runtime_v3.json').write_text(json.dumps(meta,indent=2)+'\n')
    print(json.dumps({'bbox':b,'padding_ratio':meta['safety_padding_ratio'],'luminance_error':error,'source_sha256':EXPECTED}))

if __name__ == '__main__':
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);args=p.parse_args()
    derive(args.source,ROOT/'assets/raster_shapes')

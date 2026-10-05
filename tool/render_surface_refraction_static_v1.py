"""Independent deterministic surface light study, not an approved runtime asset."""
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_SHA = '0bbc263d61b3a524b9c027e1894fab3209085d631c7a2c313d261a17ecf98ff2'

def smooth(a, b, x):
    t = np.clip((x-a)/(b-a), 0, 1)
    return t*t*(3-2*t)

def render(base_path, out):
    assert hashlib.sha256(base_path.read_bytes()).hexdigest() == BASE_SHA
    base = Image.open(base_path).convert('RGBA')
    w, h = base.size
    sh = int(h*.34)+1
    yy, xx = np.mgrid[:sh, :w].astype(np.float32)
    x, y = xx/w, yy/h
    perspective = 1/(1-y*1.82)
    u = (x-.5)*5.8*perspective
    v = 16.0*perspective
    a = u+.22*np.sin(u*1.6+v*2.8)+.10*np.sin(v*6.1-u*2.2)
    b = v+.18*np.sin(u*2.3-v*1.7)+.075*np.sin(u*4.1+v*3.9)
    rng = np.random.default_rng(10515)
    d1 = np.full((sh,w),1e6,np.float32)
    d2 = d1.copy()
    face = np.zeros((sh,w),np.float32)
    for row in np.arange(13,44,.9):
        for col in np.arange(-10,11,1.05):
            sx, sy = col+rng.uniform(-.43,.43), row+rng.uniform(-.35,.35)
            variation = rng.random()
            dist = (a-sx)**2+(b-sy)**2
            near = dist < d1
            d2 = np.where(near,d1,np.minimum(d2,dist))
            d1 = np.minimum(d1,dist)
            face = np.where(near,variation,face)
    gap = np.sqrt(d2)-np.sqrt(d1)
    uneven = .067+.044*(.5+.5*np.sin(a*2.1-b*1.6))
    rim = np.exp(-(gap/uneven)**2)
    halo = np.exp(-(gap/(uneven*2.3))**2)
    fade = 1-smooth(.16,.33,y)
    aperture = .62+.38*np.exp(-((x-.48)/.34)**2)
    energy = .71+.19*np.sin(a*1.7-b*2.3)+.10*np.sin(b*4.3+a*.9)
    interior = .15+.12*face
    alpha = np.clip((interior+(rim*.63+halo*.12)*energy)*fade*aperture,0,.93)
    # Separate broad cyan faces, cream filaments and sparse peach reflections.
    colors = np.zeros((sh,w,3),np.float32)
    colors[:,:,:] = [62,198,239]
    tint = .5+.5*np.sin(a*.83+b*1.17)
    colors += (tint[...,None]-.5)*np.array([22,22,8])
    warm = [255,248,215]
    blend = np.clip(rim*.91+halo*.15,0,1)
    colors = colors*(1-blend[...,None])+np.array(warm)*blend[...,None]
    rose = smooth(.78,.97,face)*(1-smooth(.06,.25,y))*.45
    colors = colors*(1-rose[...,None])+np.array([255,207,225])*rose[...,None]
    rgba = np.zeros((h,w,4),np.uint8)
    rgba[:sh,:,:3] = np.rint(np.clip(colors,0,255)).astype(np.uint8)
    rgba[:sh,:,3] = np.rint(alpha*255).astype(np.uint8)
    layer = Image.fromarray(rgba)
    composite = Image.alpha_composite(base,layer)
    out.mkdir(parents=True,exist_ok=True)
    layer.save(out/'surface_refraction_static_v1.png')
    composite.save(out/'surface_refraction_base_preview_v1.png')
    full_y, full_x = np.mgrid[:h,:w]
    check = ((full_x//28+full_y//28)%2)*10+30
    bg = np.full((h,w,4),255,np.uint8)
    bg[:,:,:3] = check[:,:,None]
    isolated = Image.alpha_composite(Image.fromarray(bg),layer)
    tw, th = 380, round(h*380/w)
    sheet = Image.new('RGB',(tw*3+48,th+82),'#102b40')
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',17)
    draw.text((12,10),'SURFACE REFRACTION / STATIC STUDY v1',font=font,fill='#eafaff')
    for i,(label,img) in enumerate([('APPROVED BASE',base),('ISOLATED RGBA',isolated),('BASE + SURFACE',composite)]):
        draw.text((12+i*(tw+12),40),label,font=font,fill='#b9d5e5')
        sheet.paste(img.resize((tw,th),Image.Resampling.LANCZOS),(12+i*(tw+12),68))
    sheet.save(out/'surface_refraction_review_v1.jpg',quality=94)
    assert not rgba[int(h*.45):,:,3].any()
    changed_lower = int(np.count_nonzero(np.asarray(base)[int(h*.45):]!=np.asarray(composite)[int(h*.45):]))
    assert changed_lower == 0
    assert hashlib.sha256(base_path.read_bytes()).hexdigest() == BASE_SHA
    metadata = dict(status='static_art_direction_candidate_not_approved',scope='surface_only',imagegen=False,
        width=w,height=h,seed=10515,base_sha256=BASE_SHA,motion_implemented=False,labs_changed=False,
        zero_alpha_below_fraction=.45,changed_lower_pixels=changed_lower,
        files={p.name:dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in out.glob('*') if p.suffix in ('.png','.jpg')})
    (out/'surface_refraction_static_v1.json').write_text(json.dumps(metadata,indent=2)+'\n')
    print(json.dumps(metadata))

if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--base',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    render(args.base,args.output)

"""Reference study only: estimate density, not exact alpha extraction.
Input is the user 76252.png review sheet. Never a Production Master.
"""
import argparse, hashlib, json
from pathlib import Path
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter

p=argparse.ArgumentParser()
p.add_argument('reference')
p.add_argument('--output', default='assets/backgrounds/drop01/volumetric_a_texture_study_r22.png')
a=p.parse_args()
src=Image.open(a.reference).convert('RGB')
assert src.size == (1536,1024), src.size
crop=np.asarray(src.crop((634,65,927,501)),dtype=float)/255
# A checker-contaminated review crop cannot yield an exact source alpha.
# Low-pass removes checker detail; conservative bottom-water colour is subtracted.
blur=gaussian_filter(crop, sigma=(4,1.5,0))
bg=np.median(blur[-50:].reshape(-1,3), axis=0)
y=np.linspace(0,1,crop.shape[0])[:,None]
# Density from blue excess; warm source detail contributes through luminance.
d=np.maximum(0,(blur[:,:,2]-bg[2])/(1-bg[2]))
d=np.maximum(d, np.maximum(0,(blur.mean(2)-bg.mean())/(1-bg.mean())))
def smooth(lo,hi,v):
 t=np.clip((v-lo)/(hi-lo),0,1)
 return t*t*(3-2*t)
alpha=np.clip(np.power(d,0.9)*1.15,0,.62)*(1-smooth(.36,.66,y))
# Suppress low-level haze so blue gaps survive; keep the reference fan intact.
alpha=np.maximum(0,alpha-.035)
t=smooth(.02,.24,y)[...,None]
rgb=np.broadcast_to(np.array([1,.974,.89])*(1-t)+np.array([.74,.93,1])*t,(*alpha.shape,3)).copy()
rgb[alpha==0]=0
out=np.dstack([rgb,alpha])
encoded=np.uint8(np.round(out*255))
encoded[encoded[:,:,3]==0,:3]=0
Image.fromarray(encoded,'RGBA').save(a.output,optimize=True)
b=Path(a.output).read_bytes()
meta={'role':'reference_density_texture_study','status':'qa_candidate','production_master':False,'imagegen':False,'exact_alpha_extraction':False,'source_sha256':hashlib.sha256(Path(a.reference).read_bytes()).hexdigest(),'source_canvas':[1536,1024],'reference_crop':[634,65,927,501],'texture_canvas':[293,436],'method':'4px vertical / 1.5px horizontal Gaussian checker suppression, bottom-water subtraction, blue/luminance density estimation, authored cream-to-cyan colour, mid-water alpha fade','limitations':['low-resolution baked checker reference','estimated density, not source pixels or original alpha','static art and Web motion approval pending'],'runtime_asset':a.output,'sha256':hashlib.sha256(b).hexdigest(),'byte_size':len(b)}
Path('docs/backgrounds/VOLUMETRIC_A_TEXTURE_STUDY_R22.json').write_text(json.dumps(meta,indent=2)+'\n')
print(json.dumps(meta))

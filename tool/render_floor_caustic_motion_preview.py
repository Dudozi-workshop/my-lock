"""Offline motion QA preview matching the R30 Dart painter's parameters.

This is not Flutter/browser playback proof. Requires numpy and Pillow.
"""
import argparse
import hashlib
import math
from pathlib import Path
import numpy as np
from PIL import Image


def frame(texture, size, seconds, visible_motion=True):
    w,h=size
    phase=seconds/24*2*math.pi
    scale=max(w/texture.width,h/texture.height)
    width,height=texture.width*scale,texture.height*scale
    left,origin=(w-width)/2,(h-height)/2
    start=max(0,math.floor(origin+height*.655))
    alpha_image=Image.new('RGBA',size)
    xs=np.arange(w)/w
    strength=.30*(.5-.5*math.cos(phase*2))
    # The native painter linearly interpolates these same 25 stops.
    stops=1-strength*(.5+.5*np.sin(np.arange(25)/24*math.pi*5-phase*3))
    horizontal=np.interp(xs,np.arange(25)/24,stops)
    bands=96 if visible_motion else 48
    lateral_gain=3 if visible_motion else 1
    stretch_gain=2.6 if visible_motion else 1
    vertical_gain=2.3 if visible_motion else 1
    for band in range(bands):
        top=math.floor(start+(h-start)*band/bands)
        bottom=h if band==bands-1 else math.floor(start+(h-start)*(band+1)/bands)
        if bottom<=top: continue
        y=((top+bottom)/2-origin)/height
        depth=min(1,max(0,(y-.655)/.345))
        shift=width*depth*lateral_gain*(.009*math.sin(phase*3)*math.sin(y*19)+.004*math.sin(phase*5)*math.cos(y*31))
        stretch=1+depth*stretch_gain*.025*math.sin(phase*4)*math.sin(y*17)
        vertical=height*depth*vertical_gain*.0015*math.sin(phase*5)*math.cos(y*23)
        brightness=1-.26*(.5-.5*math.cos(phase*3))*(.5+.5*math.sin(phase*4+y*19))
        sx=texture.width/(width*stretch)
        sy=texture.height/height
        row=texture.transform((w,bottom-top),Image.Transform.AFFINE,
            (sx,0,-(left+shift-width*(stretch-1)/2)*sx,0,sy,(top-origin-vertical)*sy),
            resample=Image.Resampling.BICUBIC)
        rgba=np.array(row)
        rgba[:,:,3]=np.rint(rgba[:,:,3]*brightness*horizontal[None,:]).astype(np.uint8)
        alpha_image.paste(Image.fromarray(rgba),(0,top))
    return alpha_image


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--base',type=Path,required=True)
    p.add_argument('--texture',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    assert hashlib.sha256(a.base.read_bytes()).hexdigest()=='0bbc263d61b3a524b9c027e1894fab3209085d631c7a2c313d261a17ecf98ff2'
    assert hashlib.sha256(a.texture.read_bytes()).hexdigest()=='b09d20b24b4ebd9f933234dbb4f5982b243c5fb628a2667dd669d7dd59c93a05'
    texture=Image.open(a.texture).convert('RGBA')
    base=Image.open(a.base).convert('RGBA')
    size=(400,597)
    scale=max(size[0]/base.width,size[1]/base.height)
    bw,bh=round(base.width*scale),round(base.height*scale)
    base=base.resize((bw,bh),Image.Resampling.LANCZOS)
    base=base.crop(((bw-size[0])//2,(bh-size[1])//2,(bw-size[0])//2+size[0],(bh-size[1])//2+size[1]))
    a.output.mkdir(parents=True,exist_ok=True)
    start=np.asarray(frame(texture,size,0))[:,:,3].astype(int)
    later=np.asarray(frame(texture,size,2))[:,:,3].astype(int)
    loop=np.asarray(frame(texture,size,24))[:,:,3].astype(int)
    print({'offline_2s_changed_alpha_gt12':int(np.count_nonzero(abs(start-later)>12)),
           'offline_loop_max_alpha_delta':int(np.max(abs(start-loop)))})
    composite=Image.alpha_composite(base,frame(texture,size,0))
    composite.save(a.output/'floor_motion_reference_frame.png')
    palette=composite.convert('RGB').quantize(colors=240,method=Image.Quantize.MEDIANCUT)
    frames=[]
    for i in range(144):
        rgb=Image.alpha_composite(base,frame(texture,size,i/6)).convert('RGB')
        # Enlarged lower scene crop, where this effect actually lives.
        crop=rgb.crop((0,360,400,597)).resize((600,356),Image.Resampling.LANCZOS)
        frames.append(crop.quantize(palette=palette,dither=Image.Dither.NONE))
    frames[0].save(a.output/'floor_caustic_motion_preview_r30.gif',save_all=True,
        append_images=frames[1:],duration=[167,167,166]*48,loop=0,optimize=True,disposal=1)

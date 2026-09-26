from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
import cv2

# Input directory must contain the locked v2 master plus v2 masks/overlays.
SRC = Path("sea_turtle_v3_source")
OUT = Path("sea_turtle_v3_build")
SIZE = 2048

for d in ["source", "parts", "masks", "overlays"]:
    (OUT / d).mkdir(parents=True, exist_ok=True)

def l(path):
    return np.array(Image.open(SRC / path).convert("L"))

master = Image.open(SRC / "sea_turtle_master_v2_512.png").convert("RGBA")
alpha = l("masks/master_alpha.png")
shell = l("masks/shell_mask.png")
belly = l("masks/underbelly_mask.png")
detail = l("masks/shell_detail_mask.png")
outline = l("masks/outline_mask.png")
shadow = np.array(Image.open(SRC / "overlays/shadow_overlay.png").convert("RGBA"))[:, :, 3]
highlight = np.array(Image.open(SRC / "overlays/highlight_overlay.png").convert("RGBA"))[:, :, 3]

m = np.array(master)
m[:, :, 3] = alpha
clipped = Image.fromarray(m, "RGBA")
base = clipped.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
rgb = base.convert("RGB").filter(ImageFilter.UnsharpMask(radius=1.2, percent=58, threshold=3))
alpha_hi = Image.fromarray(alpha, "L").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
draft = Image.merge("RGBA", (*rgb.split(), alpha_hi))
arr = np.array(draft)
arr[arr[:, :, 3] == 0, :3] = 0
draft = Image.fromarray(arr, "RGBA")
draft.save(OUT / "source/sea_turtle_master_v3_2048_draft.png", optimize=True)

# Neutral F0 moving-part ownership. Boundaries intentionally extend slightly into
# the body so no old flipper outline/highlight survives on the static layer.
near_pts = np.array([
    (176,198),(191,191),(205,193),(219,206),(233,227),(247,253),
    (263,281),(281,309),(301,337),(319,353),(323,366),(317,375),
    (306,380),(291,376),(271,366),(251,352),(232,334),(215,314),
    (199,291),(187,268),(179,244),(175,221)
], np.int32)
far_pts = np.array([
    (107,211),(121,211),(136,222),(147,240),(154,261),(155,281),
    (150,305),(142,328),(133,349),(124,359),(115,355),(106,343),
    (99,327),(94,306),(92,283),(94,258),(99,233)
], np.int32)

near = np.zeros((512,512), np.uint8)
far = np.zeros((512,512), np.uint8)
cv2.fillPoly(near,[near_pts],255)
cv2.fillPoly(far,[far_pts],255)
kernel=np.ones((9,9),np.uint8)
near=cv2.dilate(near,kernel,iterations=1)
far=cv2.dilate(far,kernel,iterations=1)
far[near>0]=0
static=np.full((512,512),255,np.uint8)
static[(near>0)|(far>0)]=0

def label_up(x):
    return np.array(Image.fromarray(x,"L").resize((SIZE,SIZE),Image.Resampling.NEAREST))

a=np.array(alpha_hi)
labels={"static_body":label_up(static),"front_flipper_far_f0":label_up(far),"front_flipper_near_f0":label_up(near)}
master_np=np.array(draft)

for name,label in labels.items():
    pa=np.where(label>0,a,0).astype(np.uint8)
    p=master_np.copy()
    p[:,:,3]=pa
    Image.fromarray(p,"RGBA").save(OUT / f"parts/{name}_reference_2048.png",optimize=True)
    Image.fromarray(pa,"L").save(OUT / f"masks/{name}_alpha_2048.png",optimize=True)

# Semantic masks remain static effect surfaces.
for name,src in [("shell",shell),("belly",belly),("shell_detail",detail)]:
    Image.fromarray(src,"L").resize((SIZE,SIZE),Image.Resampling.LANCZOS).save(
        OUT / f"masks/{name}_mask_2048.png",optimize=True
    )

print("Sea Turtle v3 Canonical draft generated. Animation poses are intentionally not generated.")

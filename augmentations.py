"""
Shared augmentation pipeline for the AgroEye trainers.

The models kept failing on real-world grape photos that are backlit, dark,
overexposed or autumn-red -- conditions the old ColorJitter(0.3) never produced,
so the network never had to learn them. This pipeline widens the photometric
range (jitter + gamma + autocontrast + equalize) so the model learns lighting /
colour invariance instead of latching on to the well-lit, plain-background look
of the lab datasets.

Used by train_crop_scope_v3.py and train_disease_effb0.py.
"""
import random

from PIL import Image
from torchvision import transforms
import torchvision.transforms.functional as TF


def load_rgb(path, img_size=224):
    """Open an image, letting the JPEG decoder do the bulk of the downscaling.

    Plant Pathology ships 2048x1365 JPEGs that we immediately crop down to
    224x224, so decoding them at full size was most of the data-loading cost --
    it starved the NPU at 3% AICore while 145 of 192 cores sat idle. draft()
    tells libjpeg to decode at 1/2, 1/4 or 1/8 scale directly, which is nearly
    free. We draft to 2x the target so RandomResizedCrop's smallest crop (50%
    area, ~0.71 linear) still has more pixels than it needs -- no visible loss.
    Silently a no-op for PNG/WebP, which don't support scaled decoding.
    """
    im = Image.open(path)
    try:
        im.draft("RGB", (img_size * 2, img_size * 2))
    except Exception:
        pass
    return im.convert("RGB")


class RandomGamma:
    """Random gamma correction -- simulates exposure curves (backlit / dark / blown-out)."""

    def __init__(self, lo=0.5, hi=1.8, p=0.5):
        self.lo, self.hi, self.p = lo, hi, p

    def __call__(self, img):
        if random.random() < self.p:
            return TF.adjust_gamma(img, random.uniform(self.lo, self.hi))
        return img


def strong_train_transforms(img_size, mean, std, colour_invariant=False):
    """Geometric augs (as before) + a much wider photometric range.

    colour_invariant=True (full hue circle + random grayscale) was TRIED AND
    REVERTED -- keep it False unless you have new evidence. Do not re-run the
    experiment below without reading this first.

    The theory: species is shape, not colour, and the gate had clearly learned
    "green => apple/grape, purple => other". A purple leafroll-infected grape
    leaf scored grape 0.10; rotating that same leaf's hue to green scored
    grape 0.90; in grayscale the model guessed apple. So the colour shortcut
    was real and measurable.

    The result: it did not work. Val cost was small (99.19 -> 98.88), but on
    real photos it FAILED to fix the purple vine it was built for (other 0.85
    -> 0.91, still wrong) and REGRESSED the backlit grape leaf that already
    worked (grape 0.62 -> apple 0.47). Species went 14/15 -> 13/15.

    Why: hue-jittering a green leaf yields a uniformly recoloured green leaf.
    A real leafroll leaf has green veins against purple interveinal tissue --
    a different spatial pattern, saturation and vein contrast. Synthetic
    recolouring does not transfer to it. The probe proved colour MATTERED; it
    did not prove hue augmentation could FIX it. Real purple/autumn leaf photos
    are the fix, not more augmentation.

    Also leave it False for the disease model regardless -- lesion COLOUR is
    the signal there (rust is orange, black rot is black).
    """
    hue = 0.5 if colour_invariant else 0.12          # 0.5 == the full hue circle
    colour = [transforms.ColorJitter(0.5, 0.5, 0.4, hue)]
    if colour_invariant:
        colour.append(transforms.RandomGrayscale(p=0.25))
    return transforms.Compose([
        transforms.RandomResizedCrop(img_size, scale=(0.5, 1.0)),
        transforms.RandomHorizontalFlip(), transforms.RandomVerticalFlip(p=0.3),
        transforms.RandomRotation(35), transforms.RandomPerspective(0.3, p=0.4),
        # --- photometric: the lighting/colour-invariance fix (PIL ops, before ToTensor) ---
        *colour,
        RandomGamma(0.5, 1.8, p=0.5),                  # exposure curves
        transforms.RandomAutocontrast(p=0.3),
        transforms.RandomEqualize(p=0.2),
        transforms.RandomApply([transforms.GaussianBlur(3, (0.1, 2.0))], p=0.2),
        transforms.ToTensor(), transforms.Normalize(mean, std),
        transforms.RandomErasing(p=0.25),
    ])


def val_transforms(img_size, mean, std):
    return transforms.Compose([
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor(), transforms.Normalize(mean, std),
    ])

"""Extra REAL-WORLD training data hunted from Kaggle (2026-07).

- Niphad Grape Leaf Disease Dataset  -> real field grape (Downy/Powdery/Healthy)
- Plant Pathology (FGVC) Apple        -> real field apple (scab/rust/healthy)

Provides paths keyed to the app's 16-class taxonomy so the disease and crop-scope
trainers can merge them in. Kept separate so it's obvious what's new.
"""
import csv, glob, os

from paths import NIPHAD as _NIPHAD, PP as _PP

NIPHAD = str(_NIPHAD)   # resolved per-machine (dev box vs Ascend server)
PP = str(_PP)
EXT = (".jpg", ".jpeg", ".png", ".bmp", ".webp")
CAP = 1500  # cap per class so new data doesn't swamp the balance


def _imgs(d):
    return [f for f in glob.glob(d + "/*") if f.lower().endswith(EXT)] if os.path.isdir(d) else []


def _pp_rows():
    p = PP + "/train.csv"
    return list(csv.DictReader(open(p))) if os.path.isfile(p) else []


def _pp(label):
    return [PP + "/images/" + r["image_id"] + ".jpg" for r in _pp_rows()
            if r.get(label) == "1" and os.path.isfile(PP + "/images/" + r["image_id"] + ".jpg")]


def disease_extra():
    """{display class name -> [image paths]} for the 16-class disease model."""
    d = {
        "Grape Downy Mildew":   _imgs(NIPHAD + "/Downy Mildew"),
        "Grape Powdery Mildew": _imgs(NIPHAD + "/Powdery Mildew"),
        "Grape Healthy":        _imgs(NIPHAD + "/Healthy Leaves"),
        "Apple Scab":           _pp("scab"),
        "Apple Cedar Rust":     _pp("rust"),
        "Apple Healthy":        _pp("healthy"),
    }
    return {k: v[:CAP] for k, v in d.items() if v}


def cropscope_extra():
    """{'apple'|'grape' -> [image paths]} for the 3-way crop-scope model."""
    grape = []
    for c in ["Downy Mildew", "Powdery Mildew", "Healthy Leaves", "Bacterial Leaf Spot"]:
        grape += _imgs(NIPHAD + "/" + c)
    apple = [PP + "/images/" + r["image_id"] + ".jpg" for r in _pp_rows()
             if os.path.isfile(PP + "/images/" + r["image_id"] + ".jpg")]
    return {"apple": apple[:3000], "grape": grape[:3000]}


if __name__ == "__main__":
    de = disease_extra()
    print("disease_extra:")
    for k, v in de.items():
        print(f"  {len(v):>5}  {k}")
    ce = cropscope_extra()
    print(f"cropscope_extra: apple={len(ce['apple'])}  grape={len(ce['grape'])}")

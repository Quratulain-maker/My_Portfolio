"""Dataset locations for the trainers.

The same scripts run on two machines: the Windows dev box (datasets already in
the kagglehub cache / hand-extracted onto F:) and the Ascend 910B server
(everything pulled fresh with kagglehub into $KAGGLEHUB_CACHE). Only the roots
differ, so resolve them once here instead of hardcoding Windows paths into
every trainer.
"""
import os
from pathlib import Path

IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def _kh(slug):
    """Newest cached version dir for a kagglehub dataset slug."""
    root = Path(os.environ.get("KAGGLEHUB_CACHE", Path.home() / ".cache" / "kagglehub"))
    vs = sorted((root / "datasets" / slug / "versions").glob("*"),
                key=lambda p: int(p.name) if p.name.isdigit() else -1)
    if not vs:
        raise FileNotFoundError(f"{slug} not cached under {root} -- run get_data.py first")
    return vs[-1]


if os.name == "nt":                                   # --- dev box ---
    _KH = Path("C:/Users/atyab/.cache/kagglehub/datasets")
    _NEW = Path("F:/Work/Abasyn Project/NewData")
    PV = _KH / "abdallahalidev/plantvillage-dataset/versions/3/plantvillage dataset/color"
    PD = _KH / "nirmalsankalana/plantdoc-dataset/versions/7"
    PC_DIRS = [Path("F:/Work/Abasyn Project/plantcity_data/train/train"),
               Path("F:/Work/Abasyn Project/plantcity_data/test/test")]
    NIPHAD = (_NEW / "niphad-grape-leaf-disease-dataset-ngld-v1"
              / "Niphad Grape Leaf Disease Dataset (NGLD)"
              / "Niphad Grape Leaf Disease Dataset (NGLD)" / "Grapes Disease Dataset")
    PP = _NEW / "plantpathology-apple-dataset"
else:                                                 # --- Ascend box ---
    PV = _kh("abdallahalidev/plantvillage-dataset") / "plantvillage dataset" / "color"
    PD = _kh("nirmalsankalana/plantdoc-dataset")
    _PC = _kh("codewithsk/plantcity-a-comprehensive-images-multicrop-leaves")
    PC_DIRS = [_PC / "train" / "train", _PC / "test" / "test"]
    NIPHAD = (_kh("siamahmedsiam/niphad-grape-leaf-disease-dataset-ngld-v1")
              / "Niphad Grape Leaf Disease Dataset (NGLD)"
              / "Niphad Grape Leaf Disease Dataset (NGLD)" / "Grapes Disease Dataset")
    PP = _kh("piantic/plantpathology-apple-dataset")


def check():
    for name in ("PV", "PD", "NIPHAD", "PP"):
        p = globals()[name]
        print(f"  {'OK ' if p.exists() else 'MISS'} {name:7} {p}")
    for p in PC_DIRS:
        print(f"  {'OK ' if p.exists() else 'MISS'} PC      {p}")


if __name__ == "__main__":
    check()

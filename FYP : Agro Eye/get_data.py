"""Download every dataset the AgroEye trainers need, into the kagglehub cache.

This is the script paths.py points you at when a dataset is missing:

    FileNotFoundError: <slug> not cached under <root> -- run get_data.py first

Usage (Ascend server):

    export KAGGLEHUB_CACHE=/data/agroeye/kagglehub     # or wherever you want it
    python get_data.py

Credentials: kagglehub needs a Kaggle API token. Provide it EITHER as
environment variables:

    export KAGGLE_USERNAME=<your-username>
    export KAGGLE_KEY=<your-api-key>

or as a token file at ~/.kaggle/kaggle.json (chmod 600):

    {"username": "<your-username>", "key": "<your-api-key>"}

Get a fresh token from https://www.kaggle.com/settings -> API -> Create New
Token. Do not paste a token into a notebook cell -- notebooks are saved to disk
with their source intact, so the key stays readable to anyone with access.

Re-running is safe: kagglehub skips datasets that are already cached.
"""
import os
import sys
import time
from pathlib import Path

# slug -> what it is used for, so a failure says which stage it breaks
DATASETS = [
    ("abdallahalidev/plantvillage-dataset",
     "PlantVillage (lab) -- disease base, crop-scope, leaf-gate positives"),
    ("nirmalsankalana/plantdoc-dataset",
     "PlantDoc (field) -- disease, crop-scope, leaf-gate positives"),
    ("codewithsk/plantcity-a-comprehensive-images-multicrop-leaves",
     "PlantCity (52 crops) -- extra diseases + the crop-scope 'other' class"),
    ("siamahmedsiam/niphad-grape-leaf-disease-dataset-ngld-v1",
     "Niphad NGLD (field vineyard) -- real grape leaves"),
    ("piantic/plantpathology-apple-dataset",
     "Plant Pathology (field orchard) -- real apple leaves"),
    ("prasunroy/natural-images",
     "Natural Images -- leaf-gate negatives (non-leaf objects)"),
]


def have_credentials():
    if os.environ.get("KAGGLE_USERNAME") and os.environ.get("KAGGLE_KEY"):
        return True, "environment variables"
    for c in (Path.home() / ".kaggle" / "kaggle.json",
              Path.home() / ".config" / "kaggle" / "kaggle.json"):
        if c.exists():
            return True, str(c)
    return False, None


def human(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024:
            return f"{n:,.1f} {unit}"
        n /= 1024
    return f"{n:,.1f} PB"


def dir_size(p):
    total = 0
    for root, _, files in os.walk(p):
        for f in files:
            try:
                total += os.path.getsize(os.path.join(root, f))
            except OSError:
                pass
    return total


def main():
    cache = os.environ.get("KAGGLEHUB_CACHE", str(Path.home() / ".cache" / "kagglehub"))
    print(f"Cache root : {cache}")
    print(f"Datasets   : {len(DATASETS)}")

    ok, where = have_credentials()
    if not ok:
        print("\nERROR: no Kaggle credentials found.\n"
              "  Set KAGGLE_USERNAME and KAGGLE_KEY, or create ~/.kaggle/kaggle.json\n"
              "  Token: https://www.kaggle.com/settings -> API -> Create New Token",
              file=sys.stderr)
        return 1
    print(f"Credentials: found ({where})\n")

    try:
        import kagglehub
    except ImportError:
        print("ERROR: kagglehub is not installed.  pip install kagglehub", file=sys.stderr)
        return 1

    results, failed = [], []
    for i, (slug, purpose) in enumerate(DATASETS, 1):
        print(f"[{i}/{len(DATASETS)}] {slug}")
        print(f"        {purpose}")
        t0 = time.time()
        try:
            path = kagglehub.dataset_download(slug)
            size = dir_size(path)
            dt = time.time() - t0
            print(f"        OK  {human(size)} in {dt:,.0f}s -> {path}\n", flush=True)
            results.append((slug, path, size))
        except Exception as e:
            print(f"        FAILED: {type(e).__name__}: {e}\n", file=sys.stderr, flush=True)
            failed.append((slug, e))

    print("=" * 72)
    print(f"Downloaded {len(results)}/{len(DATASETS)}  "
          f"total {human(sum(r[2] for r in results))}")
    if failed:
        print(f"\n{len(failed)} FAILED:")
        for slug, e in failed:
            print(f"  {slug}: {type(e).__name__}: {e}")

    # Confirm the trainers can actually resolve every path they need.
    print("\nResolving trainer paths (paths.py):")
    try:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import paths
        paths.check()
    except Exception as e:
        print(f"  could not run paths.check(): {type(e).__name__}: {e}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

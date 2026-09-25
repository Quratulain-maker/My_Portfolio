"""Device selection shared by the trainers.

These scripts run on two very different machines:

  * the dev box   -- GTX 1080 Ti (cuda), 16 GB RAM. DataLoader workers +
                     pinned memory exhaust that RAM and surface as a bogus
                     "CUDA error: unknown error", so it gets 0 workers.
  * the Ascend box -- 8x Ascend 910B (npu, via torch_npu), 192 cores, 2 TB RAM.
                     Plenty of headroom, so it gets real workers.

torch_npu must be imported before touching torch.npu -- importing it is what
registers the backend.
"""
import os
import random

import numpy as np
import torch


def pick_device():
    """-> (torch.device, kind) where kind is 'npu' | 'cuda' | 'cpu'."""
    try:
        import torch_npu  # noqa: F401  (import registers the npu backend)
        if torch.npu.is_available():
            return torch.device("npu:0"), "npu"
    except Exception:
        pass
    if torch.cuda.is_available():
        return torch.device("cuda"), "cuda"
    return torch.device("cpu"), "cpu"


def seed_all(s, kind):
    random.seed(s); np.random.seed(s); torch.manual_seed(s)
    if kind == "cuda":
        torch.cuda.manual_seed_all(s)
    elif kind == "npu":
        import torch_npu
        torch_npu.npu.manual_seed_all(s)


def synchronize(kind):
    if kind == "cuda":
        torch.cuda.synchronize()
    elif kind == "npu":
        import torch_npu
        torch_npu.npu.synchronize()


def tune_backend(kind):
    if kind == "cuda":
        torch.backends.cudnn.benchmark = False   # steadier on the flaky 1080 Ti


def loader_opts(kind):
    """Workers are a RAM decision -- see the module docstring.

    On npu the workers MUST be spawned, not forked. pick_device() initialises the
    CANN context in the parent; forked children inherit it and deadlock on a
    futex (the run hangs forever at 0% AICore with no epoch ever printed).
    Spawned workers start clean. They re-import this module, which is why
    torch_npu is imported inside the functions above rather than at module level.
    """
    if kind == "npu":
        # 192 cores / 2 TB RAM, and the PIL augs are the bottleneck: at 16
        # workers the NPU sat at 3% AICore with 75% of the CPU idle.
        n = int(os.environ.get("AGROEYE_WORKERS", "64"))
        return dict(num_workers=n, pin_memory=True, persistent_workers=n > 0,
                    multiprocessing_context="spawn" if n > 0 else None)
    return dict(num_workers=0, pin_memory=False)

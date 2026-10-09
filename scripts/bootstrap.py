#!/usr/bin/env python3
"""Install pinned tools from verified HTTPS releases; validate archive hashes."""
import hashlib
import io
import os
from pathlib import Path
import platform
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / ".tools" / "bin"
ASSETS = [
    ("https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-linux-x86_64.zip",
     "00feb4fa0829a1dd72b49df2639da519a352bfe13cadcd83969e2ba2bb5693c4", ["rojo"]),
    ("https://github.com/luau-lang/luau/releases/download/0.741/luau-ubuntu.zip",
     "134dc762ad26232af83e43f98dec03ff6030dd3a4452f9408b9d50ccea025503", ["luau", "luau-analyze", "luau-compile"]),
]


def main():
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise SystemExit("Cloud bootstrap supports Linux x86_64; use official native releases on your Studio machine.")
    BIN.mkdir(parents=True, exist_ok=True)
    for url, expected, names in ASSETS:
        with urllib.request.urlopen(url, timeout=60) as response:
            archive = response.read()
        if hashlib.sha256(archive).hexdigest() != expected:
            raise SystemExit(f"SHA-256 verification failed: {url}. No tools were extracted from this archive.")
        with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
            for name in names:
                target = BIN / name
                temp = target.with_suffix(".tmp")
                temp.write_bytes(bundle.read(name))
                os.chmod(temp, 0o755)
                temp.replace(target)
        print("Verified and installed: " + ", ".join(names))


if __name__ == "__main__":
    main()

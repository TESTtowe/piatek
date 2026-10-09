#!/usr/bin/env python3
"""Compile every Luau script, check portable logic, execute tests, build Studio place."""
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / ".tools" / "bin"


def run(tool, *args, quiet=False):
    binary = BIN / tool
    if not binary.exists():
        raise SystemExit("Run python3 scripts/bootstrap.py first.")
    subprocess.run([str(binary), *map(str, args)], cwd=ROOT, check=True,
                   stdout=subprocess.DEVNULL if quiet else None)


def main():
    scripts = sorted((ROOT / "src").rglob("*.luau"))
    for source in scripts:
        run("luau-compile", source, quiet=True)
    print(f"Compiled {len(scripts)} Luau files", flush=True)
    # Studio globals require Studio's type definitions; portable domain modules are fully analyzed here.
    run("luau-analyze", *sorted((ROOT / "src/shared").glob("*.luau")))
    run("luau", "tests/campaign.spec.luau")
    (ROOT / "build").mkdir(exist_ok=True)
    run("rojo", "build", "default.project.json", "-o", "build/KrwawyPiatek.rbxlx")
    run("rojo", "build", "default.project.json", "-o", "build/KrwawyPiatek.rbxl")
    root = ET.parse(ROOT / "build/KrwawyPiatek.rbxlx").getroot()
    found = {kind: len(root.findall(f".//Item[@class='{kind}']")) for kind in ("Script", "LocalScript", "ModuleScript")}
    if found != {"Script": 1, "LocalScript": 1, "ModuleScript": 9}:
        raise SystemExit(f"Unexpected script mapping: {found}")
    print(f"Verified place script mapping: {found}")
    with zipfile.ZipFile(ROOT / "build/KrwawyPiatek-source.zip", "w", zipfile.ZIP_DEFLATED) as bundle:
        for folder in ("src", "tests", "scripts", "docs"):
            for path in sorted((ROOT / folder).rglob("*")):
                if path.is_file() and "__pycache__" not in path.parts:
                    bundle.write(path, path.relative_to(ROOT))
        for filename in ("README.md", ".gitignore", "default.project.json"):
            bundle.write(ROOT / filename, filename)
    print("PASS: logic + compile + place build. Roblox engine playtest remains required in Studio.")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as exc:
        sys.exit(exc.returncode)

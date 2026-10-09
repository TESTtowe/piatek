#!/usr/bin/env python3
"""Run the actual GUI factories against a small adapter. Not a Roblox engine test."""
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    output = ROOT / "build"
    output.mkdir(exist_ok=True)
    source = (ROOT / "tests/roblox_ui_mock.luau").read_text()
    source += "\n" + (ROOT / "src/client/UI.luau").read_text().replace("return UI\n", "")
    source += "\n" + (ROOT / "src/client/FrontEnd.luau").read_text().replace("return FrontEnd\n", "")
    source += "\n" + (ROOT / "src/client/Interaction.luau").read_text().replace("return Interaction\n", "")
    source += "\n" + (ROOT / "tests/frontend.driver.luau").read_text()
    generated = output / "frontend-check.luau"
    generated.write_text(source)
    result = subprocess.run([str(ROOT / ".tools/bin/luau"), str(generated)], cwd=ROOT,
                            check=True, text=True, capture_output=True)
    views = output / "visual"
    views.mkdir(exist_ok=True)
    for line in result.stdout.splitlines():
        if line.startswith("{"):
            scene = json.loads(line)
            (views / (scene["screen"] + ".json")).write_text(json.dumps(scene, ensure_ascii=False))
        else:
            print(line)


if __name__ == "__main__":
    main()

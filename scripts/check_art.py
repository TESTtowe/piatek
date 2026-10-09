#!/usr/bin/env python3
"""Validate the committed image payload without needing a Roblox upload or renderer."""
from pathlib import Path
import base64
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[1]


def main():
    manifest = json.loads((ROOT/'assets/manifest.json').read_text())
    png = (ROOT/'assets/menu-corridor.png').read_bytes()
    assert hashlib.sha256(png).hexdigest() == manifest['sha256'], 'Source image differs from packed asset'
    assert png[:8] == b'\x89PNG\r\n\x1a\n'
    width, height = struct.unpack('>II', png[16:24])
    assert (width, height) == (manifest['width'], manifest['height'])
    source = (ROOT/'src/client/MenuArt.luau').read_text()
    pattern = r'\{ x = (\d+), y = (\d+), width = (\d+), height = (\d+), data =\s*\[=\[([A-Za-z0-9+/=]+)\]=\]'
    encoded = re.findall(pattern, source)
    assert len(encoded) == len(manifest['tiles']) == 4
    rectangles, payloads = [], []
    for raw, expected in zip(encoded, manifest['tiles']):
        x, y, w, h = map(int, raw[:4])
        assert (x,y,w,h) == tuple(expected[k] for k in ('x','y','width','height'))
        assert 0 < w <= 1024 and 0 < h <= 1024 and x+w <= width and y+h <= height
        data = base64.b64decode(raw[4], validate=True)
        assert data[:4] == b'\x28\xb5\x2f\xfd', 'Not a Zstandard frame'
        assert len(data) == expected['compressedBytes']
        assert hashlib.sha256(data).hexdigest() == expected['compressedSha256']
        for a,b,c,d in rectangles:
            assert x+w <= a or a+c <= x or y+h <= b or b+d <= y, 'Tiles overlap'
        rectangles.append((x,y,w,h))
        payloads.append(data)
    assert sum(w*h for _,_,w,h in rectangles) == width*height, 'Tiles do not cover the complete image'
    assert manifest['decodedBytes'] == width*height*4
    print('PASS image payload: source and compressed checksums, four legal tiles, complete coverage')
    try:
        import zstandard
        from PIL import Image
    except ImportError:
        print('NOT RUN pixel comparison: install Pillow and zstandard for this optional authoring check')
        return
    original = Image.open(ROOT/'assets/menu-corridor.png').convert('RGBA')
    decoder = zstandard.ZstdDecompressor()
    for rectangle, data, tile in zip(rectangles, payloads, manifest['tiles']):
        x,y,w,h = rectangle
        pixels = decoder.decompress(data, max_output_size=w*h*4)
        assert len(pixels) == w*h*4
        assert hashlib.sha256(pixels).hexdigest() == tile['rgbaSha256']
        assert original.crop((x,y,x+w,y+h)).tobytes() == pixels, 'Decoded image does not match the source'
    print(f'PASS pixel comparison: all {width}x{height} RGBA pixels preserved exactly')


if __name__=='__main__': main()

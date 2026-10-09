#!/usr/bin/env python3
"""Capture public source pages for review. Never treats extracted text as verified facts."""
import argparse
from datetime import datetime, timezone
from html.parser import HTMLParser
import json
from pathlib import Path
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


class ArticleText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.skip = 0
        self.lines = []

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "noscript"):
            self.skip += 1

    def handle_endtag(self, tag):
        if tag in ("script", "style", "noscript"):
            self.skip = max(0, self.skip - 1)

    def handle_data(self, data):
        if not self.skip and data.strip():
            self.lines.append(data.strip())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("urls", nargs="*", default=["https://policja.pl", "https://www.pap.pl"])
    args = parser.parse_args()
    results = []
    for url in args.urls:
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme != "https" or parsed.username or parsed.password or not parsed.hostname:
            raise SystemExit("Use public HTTPS source URLs without credentials.")
        item = {"url": url, "retrieved_at": datetime.now(timezone.utc).isoformat(), "verified": False}
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "Friday-source-review/0.1"})
            with urllib.request.urlopen(request, timeout=20) as response:
                body = response.read(2_000_001)
                if len(body) > 2_000_000:
                    raise ValueError("Source exceeds 2 MB review limit")
                charset = response.headers.get_content_charset() or "utf-8"
                text = ArticleText()
                text.feed(body.decode(charset, errors="replace"))
                if "_Incapsula_Resource" in body.decode(charset, errors="replace") or len(" ".join(text.lines)) < 150:
                    raise ValueError("Response contains a browser challenge or no readable article")
                item.update(status="captured", final_url=response.url, text="\n".join(text.lines))
        except (urllib.error.URLError, ValueError) as exc:
            item.update(status="blocked", error=str(exc))
        results.append(item)
        print(item["status"], url)
    destination = ROOT / "build/research/capture.json"
    destination.parent.mkdir(parents=True, exist_ok=True)
    previous = json.loads(destination.read_text(encoding="utf-8")) if destination.exists() else []
    combined = {item["url"]: item for item in previous}
    combined.update({item["url"]: item for item in results})
    destination.write_text(json.dumps(list(combined.values()), ensure_ascii=False, indent=2), encoding="utf-8")
    print("Saved source review evidence to", destination)
    if any(item["status"] != "captured" for item in results):
        raise SystemExit(2)


if __name__ == "__main__":
    main()

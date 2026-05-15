#!/usr/bin/env python3
import re
import sys
from pathlib import Path


TYPE_HEADERS = {
    "feature": "NEW",
    "change": "CHANGES",
    "bug": "FIXES",
}

TYPE_ORDER = ("feature", "change", "bug")


def main() -> int:
    source_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("changelog.lua")
    output_path = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("CHANGELOG_NEW_VERSION.txt")

    source = source_path.read_text(encoding="utf-8")
    version_match = re.search(r'addChange\("([^"]+)",\s*{(.*?)\n}\)', source, re.DOTALL)
    if not version_match:
        print(f"Unable to find first addChange block in {source_path}", file=sys.stderr)
        return 1

    version = version_match.group(1)
    block = version_match.group(2)
    entries = {change_type: [] for change_type in TYPE_ORDER}

    for change_type, text in re.findall(
        r'\{GW\.Enum\.ChangelogType\.(\w+),\s*\[=\[(.*?)\]=\]\s*\}',
        block,
        re.DOTALL,
    ):
        if change_type in entries:
            entries[change_type].append(" ".join(text.split()))

    lines = [version]
    for change_type in TYPE_ORDER:
        if not entries[change_type]:
            continue

        lines.extend(("", TYPE_HEADERS[change_type]))
        lines.extend(f"    - {entry}" for entry in entries[change_type])

    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

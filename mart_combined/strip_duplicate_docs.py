#!/usr/bin/env python3
"""Strip duplicate {% docs %} blocks from installed domain packages.

mart_finance / mart_marketing / mart_operations each define the same shared
field docs (order_id, …). That is fine per project, but dbt requires globally
unique doc names when they are installed together as packages.

Run after `dbt deps` inside mart_combined. Only touches dbt_packages/ copies.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# Keep these on mart_finance; remove from marketing + operations package copies.
SHARED_DOC_NAMES = (
    "order_id",
    "customer_id",
    "ordered_at",
    "order_date",
    "sku",
    "store_id",
    "gross_margin_pct",
)

DOCS_BLOCK = re.compile(
    r"\{%\s*docs\s+(?P<name>\w+)\s*%\}.*?\{%\s*enddocs\s*%\}",
    re.DOTALL,
)


def strip_file(path: Path) -> int:
    text = path.read_text()
    removed = 0

    def _sub(match: re.Match[str]) -> str:
        nonlocal removed
        if match.group("name") in SHARED_DOC_NAMES:
            removed += 1
            return ""
        return match.group(0)

    new = DOCS_BLOCK.sub(_sub, text)
    new = re.sub(r"\n{3,}", "\n\n", new).strip() + "\n"
    if removed:
        path.write_text(new)
    return removed


def main() -> int:
    root = Path(__file__).resolve().parent
    packages = root / "dbt_packages"
    if not packages.is_dir():
        print("error: dbt_packages/ missing — run dbt deps first", file=sys.stderr)
        return 1

    total = 0
    for pkg in ("mart_marketing", "mart_operations"):
        docs = packages / pkg / "models" / "docs.md"
        if not docs.is_file():
            print(f"skip (missing): {docs}")
            continue
        n = strip_file(docs)
        total += n
        print(f"stripped {n} shared doc block(s) from {docs.relative_to(root)}")

    print(f"done — removed {total} duplicate doc block(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

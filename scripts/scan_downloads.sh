#!/usr/bin/env bash
# Safety scan for vendored seed CSVs (ClamAV not required).
# Verifies: SHA-256 pins, MIME type, no null bytes, valid UTF-8 CSV parse.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEEDS="$ROOT/data/seeds"

# Portable interpreter pick: Linux/macOS have python3; Windows Git Bash often python.
if command -v python3 >/dev/null 2>&1; then
	PY=python3
elif command -v python >/dev/null 2>&1; then
	PY=python
else
	echo "error: need python3 or python on PATH" >&2
	exit 1
fi

cd "$SEEDS"

echo "==> SHA-256 checksum verification"
# macOS ships `shasum`, not `sha256sum`; Linux/Git Bash ship `sha256sum`.
if command -v sha256sum >/dev/null 2>&1; then
	sha256sum -c checksums.sha256
elif command -v shasum >/dev/null 2>&1; then
	shasum -a 256 -c checksums.sha256
else
	echo "error: need sha256sum or shasum on PATH" >&2
	exit 1
fi

echo "==> File type checks"
for f in raw_customers.csv raw_orders.csv raw_items.csv raw_products.csv raw_stores.csv raw_supplies.csv; do
	[[ -f "$f" ]] || {
		echo "missing $f"
		exit 1
	}
	file "$f" | grep -qi 'csv\|text' || {
		echo "bad type: $f"
		exit 1
	}
done

"$PY" -c "
from pathlib import Path
for f in Path('.').glob('raw_*.csv'):
    if b'\x00' in f.read_bytes():
        raise SystemExit(f'null byte in {f}')
print('  no null bytes')
"

echo "==> CSV structure parse"
"$PY" <<'PY'
import csv
from pathlib import Path

# Max bytes per file (raw_orders / raw_items are multi-MB by design).
MAX_BYTES = 20_000_000
expected = {
    "raw_customers.csv": {"id", "name"},
    "raw_orders.csv": {"id", "customer", "ordered_at", "store_id",
                       "subtotal", "tax_paid", "order_total"},
    "raw_items.csv": {"id", "order_id", "sku"},
    "raw_products.csv": {"sku", "name", "type", "price", "description"},
    "raw_stores.csv": {"id", "name", "opened_at", "tax_rate"},
    "raw_supplies.csv": {"id", "name", "cost", "perishable", "sku"},
}
for name, cols in expected.items():
    p = Path(name)
    size = p.stat().st_size
    if size > MAX_BYTES:
        raise SystemExit(f"{name}: unexpectedly large ({size} bytes)")
    with p.open(encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh)
        header = set(reader.fieldnames or [])
        if header != cols:
            raise SystemExit(f"{name}: bad columns {header}")
        n = sum(1 for _ in reader)
    if n == 0:
        raise SystemExit(f"{name}: empty")
    print(f"  OK {name}: {n} rows")
PY

echo "SCAN OK — seeds passed integrity checks"

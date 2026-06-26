#!/usr/bin/env bash
# Safety scan for vendored seed CSVs (ClamAV not required).
# Verifies: SHA-256 pins, MIME type, no null bytes, valid UTF-8 CSV parse.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEEDS="$ROOT/data/seeds"

cd "$SEEDS"

echo "==> SHA-256 checksum verification"
sha256sum -c checksums.sha256

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

python3 -c "
from pathlib import Path
for f in Path('.').glob('raw_*.csv'):
    if b'\x00' in f.read_bytes():
        raise SystemExit(f'null byte in {f}')
print('  no null bytes')
"

echo "==> CSV structure parse"
python3 <<'PY'
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

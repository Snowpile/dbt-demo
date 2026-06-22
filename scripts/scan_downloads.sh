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
for f in raw_customers.csv raw_orders.csv raw_payments.csv; do
  [[ -f "$f" ]] || { echo "missing $f"; exit 1; }
  file "$f" | grep -qi 'csv\|text' || { echo "bad type: $f"; exit 1; }
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

expected = {
    "raw_customers.csv": {"id", "first_name", "last_name"},
    "raw_orders.csv": {"id", "user_id", "order_date", "status"},
    "raw_payments.csv": {"id", "order_id", "payment_method", "amount"},
}
for name, cols in expected.items():
    p = Path(name)
    text = p.read_text(encoding="utf-8")
    if len(text) > 50_000:
        raise SystemExit(f"{name}: unexpectedly large ({len(text)} bytes)")
    rows = list(csv.DictReader(text.splitlines()))
    if not rows:
        raise SystemExit(f"{name}: empty")
    if set(rows[0].keys()) != cols:
        raise SystemExit(f"{name}: bad columns {rows[0].keys()}")
    print(f"  OK {name}: {len(rows)} rows")
PY

echo "SCAN OK — seeds passed integrity checks"

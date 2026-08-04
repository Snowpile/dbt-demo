#!/usr/bin/env bash
# Safety scan for vendored seed CSVs (ClamAV not required).
# Verifies: SHA-256 pins, MIME type, no null bytes, valid UTF-8 CSV parse.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"
SEEDS="$DBT_DEMO_ROOT/data/seeds"

# Prefer repo .venv (from setup.sh / uv). Avoid Windows Store "python" stubs on PATH.
PY=""
for candidate in "$DBT_DEMO_PYTHON" "${DBT_DEMO_PYTHON}.exe" "$DBT_DEMO_VENV_BIN/python.exe" "$DBT_DEMO_VENV_BIN/python"; do
	if [[ -x "$candidate" ]] || [[ -f "$candidate" ]]; then
		PY="$candidate"
		break
	fi
done
if [[ -z "$PY" ]]; then
	if command -v python3 >/dev/null 2>&1; then
		PY=$(command -v python3)
	elif command -v python >/dev/null 2>&1; then
		PY=$(command -v python)
	fi
fi
if [[ -z "$PY" ]]; then
	echo "error: no Python found. Run: . ./setup.sh" >&2
	echo "(That creates .venv via uv — do not use the Microsoft Store python shortcut.)" >&2
	exit 1
fi
# Reject Windows App Execution Alias stub (prints Store message, exit 9009).
if ! "$PY" -c "import sys; assert sys.version_info >= (3, 11)" >/dev/null 2>&1; then
	echo "error: '$PY' is not a working Python 3.11+." >&2
	echo "Run: . ./setup.sh   # installs .venv with uv" >&2
	echo "On Windows: Settings → Apps → Advanced app settings → App execution aliases" >&2
	echo "  → turn OFF 'python.exe' / 'python3.exe' aliases if they point at the Store." >&2
	exit 1
fi

cd "$SEEDS"

echo "==> SHA-256 checksum verification"
# Strip CR so a CRLF checkout of checksums.sha256 still works (Windows autocrlf).
# Seed CSVs themselves must stay LF/binary — see .gitattributes.
CHECKSUMS="$(mktemp)"
tr -d '\r' <checksums.sha256 >"$CHECKSUMS"
# macOS ships `shasum`, not `sha256sum`; Linux/Git Bash ship `sha256sum`.
set +e
if command -v sha256sum >/dev/null 2>&1; then
	sha256sum -c "$CHECKSUMS"
	checksum_rc=$?
elif command -v shasum >/dev/null 2>&1; then
	shasum -a 256 -c "$CHECKSUMS"
	checksum_rc=$?
else
	rm -f "$CHECKSUMS"
	echo "error: need sha256sum or shasum on PATH" >&2
	exit 1
fi
set -e
rm -f "$CHECKSUMS"

if [[ "$checksum_rc" -ne 0 ]]; then
	echo "" >&2
	echo "Checksum failed. On Windows this is usually CRLF in a seed CSV" >&2
	echo "(especially raw_orders.csv). Fix:" >&2
	echo "  git rm --cached -r data/seeds && git checkout HEAD -- data/seeds" >&2
	echo "  # or: delete data/seeds/raw_orders.csv && git checkout HEAD -- data/seeds/raw_orders.csv" >&2
	echo "Confirm .gitattributes marks seeds as binary, then re-pull/renormalize." >&2
	"$PY" -c "
from pathlib import Path
for p in sorted(Path('.').glob('raw_*.csv')):
    n = p.read_bytes().count(b'\r')
    if n:
        print(f'  HINT: {p.name} contains {n} CR bytes (CRLF checkout)', flush=True)
" >&2 || true
	exit "$checksum_rc"
fi

echo "==> File type checks"
for f in raw_customers.csv raw_orders.csv raw_items.csv raw_products.csv raw_stores.csv raw_supplies.csv; do
	[[ -f "$f" ]] || {
		echo "missing $f"
		exit 1
	}
	# `file` is often missing on minimal Git Bash — skip MIME check if unavailable.
	if command -v file >/dev/null 2>&1; then
		file "$f" | grep -qi 'csv\|text' || {
			echo "bad type: $f"
			exit 1
		}
	fi
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

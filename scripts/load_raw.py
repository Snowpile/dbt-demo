"""Load vendored Jaffle Shop CSVs into DuckDB schema `raw`."""

from __future__ import annotations

import argparse
from pathlib import Path

import duckdb

TABLES = (
    "raw_customers",
    "raw_orders",
    "raw_items",
    "raw_products",
    "raw_stores",
    "raw_supplies",
)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--database", required=True, help="Path to DuckDB file")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    seeds = root / "data" / "seeds"

    con = duckdb.connect(args.database)
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    for table in TABLES:
        csv_path = seeds / f"{table}.csv"
        if not csv_path.is_file():
            raise FileNotFoundError(csv_path)
        con.execute(
            f"""
            CREATE OR REPLACE TABLE raw.{table} AS
            SELECT * FROM read_csv_auto(?, header=true)
            """,
            [str(csv_path)],
        )
        n = con.execute(f"SELECT count(*) FROM raw.{table}").fetchone()[0]
        print(f"raw.{table}: {n} rows")

    con.close()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Run ad-hoc SQL against a dbt_demo DuckDB file. Invoked by scripts/sql.sh."""

from __future__ import annotations

import argparse
import sys

import duckdb


def main() -> int:
    parser = argparse.ArgumentParser(description="Ad-hoc SQL against demo DuckDB.")
    parser.add_argument("database", help="Path to .duckdb file")
    parser.add_argument(
        "sql",
        nargs="?",
        default=None,
        help="SQL to run (omit for REPL; also accepts stdin)",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Open read-write (default is read-only)",
    )
    args = parser.parse_args()

    sql = args.sql
    if sql is None and not sys.stdin.isatty():
        sql = sys.stdin.read().strip() or None

    con = duckdb.connect(args.database, read_only=not args.write)
    try:
        if sql is not None:
            _run(con, sql)
            return 0
        return _repl(con, args.database)
    finally:
        con.close()


def _run(con: duckdb.DuckDBPyConnection, sql: str) -> None:
    rel = con.sql(sql)
    if rel is None:
        print("OK")
        return
    rel.show()


def _repl(con: duckdb.DuckDBPyConnection, database: str) -> int:
    print(f"DuckDB  {database}  (read-only; \\q to quit)", file=sys.stderr)
    buf: list[str] = []
    while True:
        try:
            prompt = "sql> " if not buf else "...> "
            line = input(prompt)
        except (EOFError, KeyboardInterrupt):
            print(file=sys.stderr)
            return 0
        if not buf and line.strip() in {r"\q", "quit", "exit"}:
            return 0
        buf.append(line)
        text = "\n".join(buf).strip()
        if not text.endswith(";"):
            continue
        buf.clear()
        try:
            _run(con, text)
        except duckdb.Error as exc:
            print(f"Error: {exc}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

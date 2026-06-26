# Seed data provenance

Source: [dbt-labs/jaffle-shop](https://github.com/dbt-labs/jaffle-shop) `seeds/jaffle-data` (jafgen-generated fictional cafe data). License: Apache 2.0.

| File | Grain | Notes |
|------|-------|-------|
| `raw_customers.csv` | one row per customer | `id, name` |
| `raw_orders.csv` | one row per order | `id, customer, ordered_at, store_id, subtotal, tax_paid, order_total` — money in **cents** |
| `raw_items.csv` | one row per order line item | `id, order_id, sku` |
| `raw_products.csv` | one row per product | `sku, name, type, price, description` — `price` in **cents** |
| `raw_stores.csv` | one row per store | `id, name, opened_at, tax_rate` |
| `raw_supplies.csv` | one row per product-supply (BOM) | `id, name, cost, perishable, sku` — `cost` in **cents** |

Coverage: ~62k orders / ~91k items across 6 stores, 2024-09-01 -> 2025-08-31.

SHA-256 pins in `checksums.sha256`. Run `scripts/scan_downloads.sh` before every load.

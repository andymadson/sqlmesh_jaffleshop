MODEL (
  name main.stg_orders,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_orders),
  audits (
    unique_values(columns = (order_id)),
    not_null(columns = (order_id, customer_id, status)),
    accepted_values(column = status, is_in = ['placed', 'shipped', 'completed', 'return_pending', 'returned'])
  )
);
WITH source AS (
  SELECT
    *
  FROM main.raw_orders
), renamed AS (
  SELECT
    id AS order_id,
    user_id AS customer_id,
    order_date,
    status
  FROM source
)
SELECT
  *
FROM renamed;
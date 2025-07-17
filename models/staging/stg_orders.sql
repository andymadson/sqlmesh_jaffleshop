MODEL (
  name main.stg_orders,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_orders)
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

AUDIT (
  name unique_order_id
);
SELECT order_id
FROM @this_model
WHERE order_id IS NOT NULL
GROUP BY order_id
HAVING COUNT(*) > 1;

AUDIT (
  name not_null_order_id
);
SELECT *
FROM @this_model
WHERE order_id IS NULL;

AUDIT (
  name accepted_order_status
);
SELECT *
FROM @this_model
WHERE status NOT IN ('placed', 'shipped', 'completed', 'return_pending', 'returned');
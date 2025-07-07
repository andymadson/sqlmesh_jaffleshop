MODEL (
  name main.stg_orders,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_orders),
  audits (
    UNIQUE_STG_ORDERS_ORDER_ID(),
    NOT_NULL_STG_ORDERS_ORDER_ID(),
    ACCEPTED_VALUES_STG_ORDERS_STATUS__PLACED__SHIPPED__COMPLETED__RETURN_PENDING__RETURNED()
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

AUDIT (
  name unique_stg_orders_order_id
);
SELECT
  "order_id" AS "unique_field",
  COUNT(*) AS "n_records"
FROM "jaffle_shop"."main"."stg_orders" AS "stg_orders"
WHERE
  NOT "order_id" IS NULL
GROUP BY
  "order_id"
HAVING
  COUNT(*) > 1;

AUDIT (
  name accepted_values_stg_orders_status__placed__shipped__completed__return_pending__returned
);
WITH "all_values" AS (
  SELECT
    "status" AS "value_field",
    COUNT(*) AS "n_records"
  FROM "jaffle_shop"."main"."stg_orders" AS "stg_orders"
  GROUP BY
    "status"
)
SELECT
  *
FROM "all_values" AS "all_values"
WHERE
  NOT "value_field" IN ('placed', 'shipped', 'completed', 'return_pending', 'returned');

AUDIT (
  name not_null_stg_orders_order_id
);
SELECT
  "order_id" AS "order_id"
FROM "jaffle_shop"."main"."stg_orders" AS "stg_orders"
WHERE
  "order_id" IS NULL;
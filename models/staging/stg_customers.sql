MODEL (
  name main.stg_customers,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_customers),
  audits (UNIQUE_STG_CUSTOMERS_CUSTOMER_ID(), NOT_NULL_STG_CUSTOMERS_CUSTOMER_ID())
);
WITH source AS (
  SELECT
    *
  FROM main.raw_customers
), renamed AS (
  SELECT
    id AS customer_id,
    first_name,
    last_name
  FROM source
)
SELECT
  *
FROM renamed;

AUDIT (
  name unique_stg_customers_customer_id
);
SELECT
  "customer_id" AS "unique_field",
  COUNT(*) AS "n_records"
FROM "jaffle_shop"."main"."stg_customers" AS "stg_customers"
WHERE
  NOT "customer_id" IS NULL
GROUP BY
  "customer_id"
HAVING
  COUNT(*) > 1;

AUDIT (
  name not_null_stg_customers_customer_id
);
SELECT
  "customer_id" AS "customer_id"
FROM "jaffle_shop"."main"."stg_customers" AS "stg_customers"
WHERE
  "customer_id" IS NULL;
MODEL (
  name main.stg_customers,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_customers),
  audits (
    unique_values(columns = (customer_id)),
    not_null(columns = (customer_id))
  )
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
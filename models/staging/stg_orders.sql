MODEL (
  name main.stg_orders,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column order_date,
    batch_size 1,
    lookback 3,
    forward_only TRUE
  ),
  start '2018-01-01',
  cron '@daily',
  grain order_date,
  dialect duckdb,
  depends_on (
    main.raw_orders
  ),
  audits (
    UNIQUE_VALUES(columns = (
      order_id
    )),
    NOT_NULL(columns = (order_id, customer_id, status)),
    ACCEPTED_VALUES(
      "column" = status,
      is_in = ['placed', 'shipped', 'completed', 'return_pending', 'returned']
    )
  ),
  partitioned_by order_date,
  clustered_by (customer_id, status),
  allow_partials TRUE
);

WITH source AS (
  SELECT
    *
  FROM main.raw_orders
  WHERE
    order_date BETWEEN @start_ds AND @end_ds
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
FROM renamed
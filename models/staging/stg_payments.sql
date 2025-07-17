MODEL (
  name main.stg_payments,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_payments),
  audits (
    unique_values(columns = (payment_id)),
    not_null(columns = (payment_id, payment_method)),
    accepted_values(column = payment_method, is_in = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'])
  )
);
WITH source AS (
  SELECT
    *
  FROM main.raw_payments
), renamed AS (
  SELECT
    id AS payment_id,
    order_id,
    payment_method,
    amount /* `amount` is currently stored in cents, so we convert it to dollars */ / 100 AS amount
  FROM source
)
SELECT
  *
FROM renamed;
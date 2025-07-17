MODEL (
  name main.stg_payments,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_payments)
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

AUDIT (
  name unique_payment_id
);
SELECT payment_id
FROM @this_model
WHERE payment_id IS NOT NULL
GROUP BY payment_id
HAVING COUNT(*) > 1;

AUDIT (
  name not_null_payment_id
);
SELECT *
FROM @this_model
WHERE payment_id IS NULL;

AUDIT (
  name accepted_payment_methods
);
SELECT *
FROM @this_model
WHERE payment_method NOT IN ('credit_card', 'coupon', 'bank_transfer', 'gift_card');
MODEL (
  name main.stg_payments,
  start '2025-01-01',
  dialect duckdb,
  depends_on (main.raw_payments),
  audits (
    UNIQUE_STG_PAYMENTS_PAYMENT_ID(),
    NOT_NULL_STG_PAYMENTS_PAYMENT_ID(),
    ACCEPTED_VALUES_STG_PAYMENTS_PAYMENT_METHOD__CREDIT_CARD__COUPON__BANK_TRANSFER__GIFT_CARD()
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

AUDIT (
  name not_null_stg_payments_payment_id
);
SELECT
  "payment_id" AS "payment_id"
FROM "jaffle_shop"."main"."stg_payments" AS "stg_payments"
WHERE
  "payment_id" IS NULL;

AUDIT (
  name unique_stg_payments_payment_id
);
SELECT
  "payment_id" AS "unique_field",
  COUNT(*) AS "n_records"
FROM "jaffle_shop"."main"."stg_payments" AS "stg_payments"
WHERE
  NOT "payment_id" IS NULL
GROUP BY
  "payment_id"
HAVING
  COUNT(*) > 1;

AUDIT (
  name accepted_values_stg_payments_payment_method__credit_card__coupon__bank_transfer__gift_card
);
WITH "all_values" AS (
  SELECT
    "payment_method" AS "value_field",
    COUNT(*) AS "n_records"
  FROM "jaffle_shop"."main"."stg_payments" AS "stg_payments"
  GROUP BY
    "payment_method"
)
SELECT
  *
FROM "all_values" AS "all_values"
WHERE
  NOT "value_field" IN ('credit_card', 'coupon', 'bank_transfer', 'gift_card');
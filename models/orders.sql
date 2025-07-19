/* This table has basic information about orders, as well as some derived facts based on payments */
MODEL (
  name main.orders,
  start '2025-01-01',
  dialect duckdb,
  kind FULL,
  depends_on (main.customers, main.stg_orders, main.stg_payments),
  audits (
    UNIQUE_VALUES(columns = (
      order_id
    )),
    NOT_NULL(
      columns = (
        order_id,
        customer_id,
        credit_card_amount,
        coupon_amount,
        bank_transfer_amount,
        gift_card_amount,
        amount
      )
    ),
    RELATIONSHIPS_ORDERS_CUSTOMER_ID__CUSTOMER_ID__REF_CUSTOMERS_(),
    ACCEPTED_VALUES(
      "column" = status,
      is_in = ['placed', 'shipped', 'completed', 'return_pending', 'returned']
    )
  ),
  allow_partials TRUE
);

JINJA_QUERY_BEGIN;
{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from main.stg_orders

),

payments as (

    select * from main.stg_payments

),

order_payments as (

    select
        order_id,

        {% for payment_method in payment_methods %}sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor %}sum(amount) as total_amount

    from payments

    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,

        {% for payment_method in payment_methods %}order_payments.{{ payment_method }}_amount,

        {% endfor %}order_payments.total_amount as amount

    from orders


    left join order_payments
        on orders.order_id = order_payments.order_id

)

select * from final
JINJA_END;;

AUDIT (
  name relationships_orders_customer_id__customer_id__ref_customers_
);

WITH "child" AS (
  SELECT
    "customer_id" AS "from_field"
  FROM "jaffle_shop"."main"."orders" AS "orders"
  WHERE
    NOT "customer_id" IS NULL
), "parent" AS (
  SELECT
    "customer_id" AS "to_field"
  FROM "jaffle_shop"."main"."customers" AS "customers"
)
SELECT
  "from_field" AS "from_field"
FROM "child" AS "child"
LEFT JOIN "parent" AS "parent"
  ON "child"."from_field" = "parent"."to_field"
WHERE
  "parent"."to_field" IS NULL
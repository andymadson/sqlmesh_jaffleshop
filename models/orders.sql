/* This table has basic information about orders, as well as some derived facts based on payments */
MODEL (
  name main.orders,
  start '2025-01-01',
  dialect duckdb,
  kind FULL,
  depends_on (main.customers, main.stg_orders, main.stg_payments),
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
JINJA_END;

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
  name not_null_customer_id
);
SELECT *
FROM @this_model
WHERE customer_id IS NULL;

AUDIT (
  name customer_relationship
);
SELECT DISTINCT o.customer_id
FROM @this_model o
LEFT JOIN main.customers c ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND c.customer_id IS NULL;

AUDIT (
  name accepted_order_status
);
SELECT *
FROM @this_model
WHERE status NOT IN ('placed', 'shipped', 'completed', 'return_pending', 'returned');

AUDIT (
  name not_null_amount
);
SELECT *
FROM @this_model
WHERE amount IS NULL;

AUDIT (
  name not_null_credit_card_amount
);
SELECT *
FROM @this_model
WHERE credit_card_amount IS NULL;

AUDIT (
  name not_null_coupon_amount
);
SELECT *
FROM @this_model
WHERE coupon_amount IS NULL;

AUDIT (
  name not_null_bank_transfer_amount
);
SELECT *
FROM @this_model
WHERE bank_transfer_amount IS NULL;

AUDIT (
  name not_null_gift_card_amount
);
SELECT *
FROM @this_model
WHERE gift_card_amount IS NULL;
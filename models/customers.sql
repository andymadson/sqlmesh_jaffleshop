/* This table has basic information about a customer, as well as some derived facts based on a customer's orders */
MODEL (
  name main.customers,
  start '2025-01-01',
  dialect duckdb,
  kind FULL,
  depends_on (main.stg_customers, main.stg_orders, main.stg_payments),
  allow_partials TRUE
);
WITH customers AS (
  SELECT
    *
  FROM main.stg_customers
), orders AS (
  SELECT
    *
  FROM main.stg_orders
), payments AS (
  SELECT
    *
  FROM main.stg_payments
), customer_orders AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_order,
    MAX(order_date) AS most_recent_order,
    COUNT(order_id) AS number_of_orders
  FROM orders
  GROUP BY
    customer_id
), customer_payments AS (
  SELECT
    orders.customer_id,
    SUM(amount) AS total_amount
  FROM payments
  LEFT JOIN orders
    ON payments.order_id = orders.order_id
  GROUP BY
    orders.customer_id
), final AS (
  SELECT
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customer_orders.first_order,
    customer_orders.most_recent_order,
    customer_orders.number_of_orders,
    customer_payments.total_amount AS customer_lifetime_value
  FROM customers
  LEFT JOIN customer_orders
    ON customers.customer_id = customer_orders.customer_id
  LEFT JOIN customer_payments
    ON customers.customer_id = customer_payments.customer_id
)
SELECT
  *
FROM final;

AUDIT (
  name unique_customer_id
);
SELECT customer_id
FROM @this_model
WHERE customer_id IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) > 1;

AUDIT (
  name not_null_customer_id
);
SELECT *
FROM @this_model
WHERE customer_id IS NULL;
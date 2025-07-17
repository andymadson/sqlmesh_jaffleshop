AUDIT (
  name assert_customer_relationship
);

WITH child AS (
  SELECT DISTINCT customer_id
  FROM @this_model
  WHERE customer_id IS NOT NULL
),
parent AS (
  SELECT DISTINCT customer_id
  FROM main.customers
)
SELECT 
  child.customer_id
FROM child
LEFT JOIN parent ON child.customer_id = parent.customer_id
WHERE parent.customer_id IS NULL;
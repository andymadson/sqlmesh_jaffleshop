MODEL (
  name main.raw_orders,
  dialect duckdb,
  kind SEED (
    path '../seeds/raw_orders.csv',
    batch_size 1000
  ),
  depends_on (),
  columns (
    id INT,
    user_id INT,
    order_date DATE,
    status TEXT
  )
)
MODEL (
  name main.raw_payments,
  dialect duckdb,
  kind SEED (
    path '../seeds/raw_payments.csv',
    batch_size 1000
  ),
  depends_on (),
  columns (
    id INT,
    order_id INT,
    payment_method TEXT,
    amount INT
  )
)
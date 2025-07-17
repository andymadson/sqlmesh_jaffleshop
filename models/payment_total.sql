MODEL (
  name main.payment_total,
  depends_on (main.orders)
);

JINJA_QUERY_BEGIN;
SELECT 
    order_id,
    credit_card_amount,
    coupon_amount,
    bank_transfer_amount,
    gift_card_amount,
    amount,
    {{ calculate_payment_totals() }}  -- This adds 2 columns
FROM main.orders
JINJA_END;
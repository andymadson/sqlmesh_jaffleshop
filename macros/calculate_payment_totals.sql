{% macro calculate_payment_totals() %}
  credit_card_amount + coupon_amount + bank_transfer_amount + gift_card_amount AS calculated_total,
  ABS(amount - (credit_card_amount + coupon_amount + bank_transfer_amount + gift_card_amount)) < 0.01 AS amounts_match
{% endmacro %}
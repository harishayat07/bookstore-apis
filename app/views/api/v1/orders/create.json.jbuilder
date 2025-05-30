json.order_id @order.id
json.customer @customer.name
json.total_price @order.total_price
json.discounts @order.calculate_discounts_summary

json.items @order.order_items do |oi|
  json.name oi.item.name
  json.quantity oi.quantity
  json.price oi.discounted_price
end

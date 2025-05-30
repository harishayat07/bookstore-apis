json.array! @orders do |order|
  json.extract! order, :id, :status, :total_price, :created_at

  json.customer do
    json.extract! order.customer, :name, :email, :membership_type
  end

  json.items order.order_items do |oi|
    json.id oi.item.id
    json.name oi.item.name
    json.quantity oi.quantity
    json.price oi.discounted_price || oi.item.price
  end

  discount_data = order.calculate_discounts_summary

  json.membership_discount discount_data[:membership_discount]
  json.bogo_discount discount_data[:bogo_discount]
  json.total_discount discount_data[:total_discount]
end

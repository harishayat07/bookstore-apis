class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items
  has_many :items, through: :order_items

  enum status: {
    pending: "pending",
    confirmed: "confirmed",
    ready_for_pickup: "ready_for_pickup",
    shipped: "shipped"
  }

  def calculate_discounts_summary
    membership_discount = case customer.membership_type
                          when "gold" then 0.10
                          when "platinum" then 0.15
                          else 0.05
                          end

    book_items = order_items.select { |oi| oi.item.category == 'book' }
    buy_one_get_one_discount = 0

    book_items.each_with_index do |oi, idx|
      next if idx.odd?
      half_price = oi.item.price * 0.5
      buy_one_get_one_discount += half_price
    end

    total_discount = buy_one_get_one_discount + (total_price * membership_discount)

    {
      membership_discount: (total_price * membership_discount).round(2),
      bogo_discount: buy_one_get_one_discount.round(2),
      total_discount: total_discount.round(2)
    }
  end
end

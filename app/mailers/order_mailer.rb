class OrderMailer < ApplicationMailer
  default from: "no-reply@bookstore.com"

  def ready_for_pickup(order)
    @order = order
    @customer = order.customer
    @discounts = order.calculate_discounts_summary

    mail(to: @customer.email, subject: "Your order ##{order.id} is ready for pickup!")
  end
end

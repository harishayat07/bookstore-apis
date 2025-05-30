class Api::V1::OrdersController < ApplicationController
  def index
    @orders = Order.includes(:customer, order_items: :item).order(created_at: :desc)
  end

  def create
    ActiveRecord::Base.transaction do
      customer_params = params.require(:customer).permit(:name, :email, :membership_type)
      @customer = Customer.find_or_create_by(email: customer_params[:email]) do |c|
        c.name = customer_params[:name]
        c.membership_type = customer_params[:membership_type]
      end

      @order = @customer.orders.create!(status: "pending", total_price: 0)

      total = 0

      params[:items].each do |item_param|
        item = Item.find(item_param[:item_id])
        quantity = item_param[:quantity].to_i
        price = item.price * quantity

        @order.order_items.create!(
          item: item,
          quantity: quantity,
          discounted_price: price
        )

        total += price
      end

      @order.update!(total_price: total)
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    order = Order.find(params[:id])
    if order.update(status: params[:status])
      render json: { message: "Order updated", status: order.status }, status: :ok
    else
      render json: { error: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    order = Order.find(params[:id])
    if order.update(status: params[:status])
      OrderMailer.ready_for_pickup(order).deliver_later if params[:status] == "ready_for_pickup"

      render json: { message: "Order updated", status: order.status }, status: :ok
    else
      render json: { error: order.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

class PaymentsController < ApplicationController
  before_action :set_order

  def create
    customer = Stripe::Customer.create(
      source: params[:stripeToken],
      email:  params[:stripeEmail]
      )

    charge = Stripe::Charge.create(
    customer:     customer.id,   # You should store this customer id and re-use it.
    amount:       @order.amount_cents, # or amount_pennies
    description:  "Payment for teddy #{@order.user_id} for order #{@order.id}",
    currency:     @order.amount.currency
    )

    @order.update(payment: charge.to_json, paid_status: true)
    current_user.orders.create(paid_status: false)
    redirect_to done_path(@order)

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_order_payment_path(@order)
  end

  private

  def set_order
    @order = current_user.orders.where(paid_status: false).find(params[:order_id])
  end
end
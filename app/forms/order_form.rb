# frozen_string_literal: true

class OrderForm < ApplicationForm
  attribute :address_id, :string

  attr_accessor :current_cart, :current_user
  attr_reader :order

  validates :address_id, presence: true

  private

  def submit
    @order = Order.new(
      workflow_status: 'pending',
      subtotal: current_cart.total_price,
      total: current_cart.total_price,
      address_attributes: address_attributes,
      items_attributes: items_attributes,
      user: current_user
    )

    @order.save!
    current_cart.clear
  end

  def address_attributes
    address = Address.find(address_id)

    address.dup.attributes.except('id', 'created_at', 'updated_at').tap do |hash|
      hash['default'] = false
    end
  end

  def items_attributes
    current_cart.items.map do |item|
      {
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.price
      }
    end
  end
end

# frozen_string_literal: true

class OrderForm < ApplicationForm
  attribute :address_id, :string
  attribute :requires_invoice, :string

  attr_accessor :current_cart, :current_user
  attr_reader :order

  validates :address_id, presence: true

  private

  def submit
    @order = Order.new(order_attributes)

    @order.save!
    Order.where(id: @order.id).update_all(label_price_snapshot: label_price_snapshot.to_json) # rubocop:disable Rails/SkipsModelValidations
  end

  def order_attributes # rubocop:disable Metrics/MethodLength
    {
      workflow_status: 'draft',
      subtotal: current_cart.subtotal_price,
      total: current_cart.total_price,
      address_attributes: address_attributes,
      items_attributes: items_attributes,
      user: current_user,
      label_price: label_price.price,
      locale: I18n.locale.to_s,
      requires_invoice: parse_requires_invoice
    }
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
        price_mxn: item.product.translations.for_locale(:es).price,
        price_usd: item.product.translations.for_locale(:en).price
      }
    end
  end

  def label_price_snapshot
    {
      label_price_id: label_price.id,
      captured_at: Time.current,
      weight_applied: current_cart.total_weight
    }.merge(
      label_price.attributes.slice('product_type', 'range_start', 'range_end', 'price_mxn', 'price_usd', 'unit')
    )
  end

  def label_price
    @label_price ||= LabelPrice.find_price(current_cart.total_weight, 'Book')
  end

  def parse_requires_invoice
    return false if requires_invoice.blank?

    ActiveModel::Type::Boolean.new.cast(requires_invoice)
  end
end

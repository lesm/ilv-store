# frozen_string_literal: true

class OrderForm < ApplicationForm
  class UnpublishedProductsError < StandardError; end

  attribute :address_id, :string
  attribute :requires_invoice, :string

  attr_accessor :current_cart, :current_user
  attr_reader :order

  validates :address_id, presence: true
  validate :cart_products_published

  private

  def cart_products_published
    errors.add(:base, :unpublished_products) if current_cart.products.unpublished.exists?
  end

  # The validation above runs before the transaction, so an admin could hide a
  # product in between. Lock the cart's products and check again: a concurrent
  # unpublish either commits first and is seen here, or waits until this order
  # (and its stock reservation) is committed. Locking in id order up front also
  # means two checkouts never lock the same products in different orders.
  def ensure_cart_products_published!
    products = Product.where(id: current_cart.items.select(:product_id)).order(:id).lock
    return if products.all?(&:published?)

    raise UnpublishedProductsError, errors.generate_message(:base, :unpublished_products)
  end

  def submit
    ensure_cart_products_published!
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
      hash['is_default'] = false
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

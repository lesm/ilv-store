# frozen_string_literal: true

class Cart < ApplicationRecord
  include Broadcastable

  belongs_to :user
  belongs_to :label_price, optional: true

  has_many :items, class_name: 'Cart::Item', dependent: :destroy
  has_many :products, through: :items

  delegate :price, to: :label_price, prefix: true, allow_nil: true

  def products_price
    items.sum { |item| item.price * item.quantity }
  end
  alias_method :subtotal_price, :products_price

  def total_price
    return 0 if items.empty?

    products_price + (label_price_price || 0)
  end

  def total_weight
    items.includes(product: :productable).sum { |item| item.product.productable.weight_grams / 1000.0 * item.quantity }
  end

  def number_of_items
    items.sum(&:quantity)
  end

  def clear
    items.delete_all
    update(label_price_id: nil)
  end

  def update_label_price
    price = LabelPrice.find_price(total_weight, 'Book')
    update(label_price_id: price.id)
  rescue ActiveRecord::RecordNotFound
    update(label_price_id: nil)
  end
end

# frozen_string_literal: true

class Cart < ApplicationRecord
  include Broadcastable

  belongs_to :user
  belongs_to :label_price, dependent: :destroy

  has_many :items, class_name: 'Cart::Item', dependent: :destroy
  has_many :products, through: :items

  delegate :price, to: :label_price, prefix: true, allow_nil: true

  def products_price
    items.sum { it.price * it.quantity }
  end

  def total_price
    return 0 if items.empty?

    products_price + label_price_price
  end

  def total_weight
    items.sum { it.product.productable.weight_grams / 1000.0 * it.quantity }
  end

  def number_of_items
    items.map(&:quantity).sum
  end

  def clear
    items.delete_all
    update(label_price_id: nil)
  end

  def update_label_price
    price = LabelPrice.find_price('Book', total_weight)
    update(label_price_id: price.id)
  rescue ActiveRecord::RecordNotFound
    update(label_price_id: nil)
  end
end

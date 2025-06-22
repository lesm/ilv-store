# frozen_string_literal: true

class Cart < ApplicationRecord
  include Broadcastable

  belongs_to :user

  has_many :items, class_name: 'Cart::Item', dependent: :destroy
  has_many :products, through: :items

  def total_price
    items.sum { it.price * it.quantity }
  end

  def number_of_items
    items.map(&:quantity).sum
  end

  def clear
    items.destroy_all
  end
end

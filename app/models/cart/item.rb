# frozen_string_literal: true

class Cart
  class Item < ApplicationRecord
    belongs_to :product
    belongs_to :cart, touch: true

    validates :quantity, numericality: { greater_than: 0 }

    delegate :name, :price, to: :product, prefix: false
  end
end

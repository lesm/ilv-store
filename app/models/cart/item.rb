# frozen_string_literal: true

class Cart
  class Item < ApplicationRecord
    belongs_to :product
    belongs_to :cart

    validates :quantity, numericality: { greater_than: 0 }
  end
end

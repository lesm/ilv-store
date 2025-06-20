# frozen_string_literal: true

class Order
  class Item < ApplicationRecord
    belongs_to :order
    belongs_to :product

    validates :quantity, numericality: { greater_than: 0 }
    validates :quantity, :price, presence: true

    delegate :title_mx, to: :product, prefix: true
  end
end

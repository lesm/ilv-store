# frozen_string_literal: true

class LabelPrice < ApplicationRecord
  PRODUCT_TYPES = %w[Book].freeze
  UNITS = %w[kg].freeze

  validates :product_type, inclusion: { in: PRODUCT_TYPES }
  validates :unit, inclusion: { in: UNITS }
  validates :product_type, :range_start, :range_end, :price, :unit, presence: true
  validates :range_start, :range_end, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than: 0 }
  validates :range_end, numericality: { greater_than: :range_start }, if: -> { range_start && range_end }
end

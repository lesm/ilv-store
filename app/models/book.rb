# frozen_string_literal: true

class Book < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy, required: true
  accepts_nested_attributes_for :product

  validates :language, :language_zone, :edition_number, :pages_number,
            :cover_color, :dimensions, :weight_grams, presence: true
  validates :internal_code, presence: true, uniqueness: true

  validate :propagate_product_errors

  private

  def propagate_product_errors
    return if product.blank? || product.valid?

    product.errors.each do |error|
      errors.add(:"product_#{error.attribute}", error.message)
    end
  end
end

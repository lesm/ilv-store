# frozen_string_literal: true

class Book < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy, required: true

  validates :language, :language_zone, :edition_number, :pages_number,
            :cover_color, :dimensions, :weight_grams, presence: true
  validates :internal_code, presence: true, uniqueness: true

  accepts_nested_attributes_for :product
end

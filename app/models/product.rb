# frozen_string_literal: true

class Product < ApplicationRecord
  validates :original_title, :title_mx, :language, :language_zone,
            :edition_number, :pages_number, presence: true
  validates :internal_code, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :price_mx, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than: 0 }
end

# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true

  validates :original_title, :title_mx, presence: true
  validates :price_mx, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than: 0 }
end

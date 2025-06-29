# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  has_one :translation, class_name: 'Product::Translation', dependent: :destroy, required: true

  validates :stock, presence: true, numericality: { greater_than: 0 }

  delegate :title, :subtitle, :price, to: :translation

  accepts_nested_attributes_for :translation
end

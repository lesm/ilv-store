# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  has_one :translation,
          lambda {
            where(locale: I18n.locale)
          }, class_name: 'Product::Translation', inverse_of: :product, dependent: :destroy, required: true
  has_one_attached :cover do |attachable|
    attachable.variant :small, resize_to_limit: [300, 300]
    attachable.variant :medium, resize_to_limit: [600, 600]
  end

  validates :stock, presence: true, numericality: { greater_than: 0 }

  delegate :title, :subtitle, :price, to: :translation

  accepts_nested_attributes_for :translation
end

# frozen_string_literal: true

class Product < ApplicationRecord
  include Searchable
  include TypesenseConfig
  include InventoryManageable

  belongs_to :productable, polymorphic: true

  has_many :translations, class_name: 'Product::Translation', inverse_of: :product, dependent: :destroy do
    def for_locale(locale = I18n.locale)
      find { |t| t.locale == locale.to_s }
    end
  end
  has_many :order_items, class_name: 'Order::Item', dependent: :restrict_with_error
  has_many :cart_items, class_name: 'Cart::Item', dependent: :restrict_with_error

  accepts_nested_attributes_for :translations

  has_one_attached :cover do |attachable|
    attachable.variant :small, resize_to_limit: [300, 300]
    attachable.variant :medium, resize_to_limit: [600, 600]
  end

  validates :translations, presence: true
  validate :cover_image_type

  delegate :title, :subtitle, :price, to: :current_translation

  def current_translation = translations.for_locale

  private

  def cover_image_type
    return unless cover.attached?
    return if cover.content_type.in?(%w[image/png image/jpg image/jpeg])

    errors.add(:cover, :invalid_image_type)
  end
end

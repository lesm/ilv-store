# frozen_string_literal: true

class LabelPrice < ApplicationRecord
  PRODUCT_TYPES = %w[Book].freeze
  UNITS = %w[kg].freeze

  has_many :carts, dependent: :restrict_with_error

  validates :product_type, inclusion: { in: PRODUCT_TYPES }
  validates :unit, inclusion: { in: UNITS }
  validates :product_type, :range_start, :range_end, :price_mxn, :price_usd, :unit, presence: true
  validates :range_start, :range_end, numericality: { greater_than_or_equal_to: 0 }
  validates :price_mxn, :price_usd, numericality: { greater_than: 0 }
  validates :range_end, numericality: { greater_than: :range_start }, if: -> { range_start && range_end }

  def self.find_price(weight, product_type = 'Book')
    label_price = where(product_type:)
                  .where('range_start <= ? AND range_end >= ?', weight, weight)
                  .order(price_mxn: :asc)
                  .first

    if label_price.nil?
      Sentry.capture_message("No LabelPrice found for product_type: #{product_type}, weight: #{weight}")

      raise ActiveRecord::RecordNotFound, 'No LabelPrice found for the given weight'
    end

    label_price
  end

  def price
    price_for_locale
  end

  private

  def price_for_locale(locale = I18n.locale)
    currency = Order::CURRENCIES[locale.to_sym]
    public_send("price_#{currency.downcase}")
  end
end

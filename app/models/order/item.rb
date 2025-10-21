# frozen_string_literal: true

class Order
  class Item < ApplicationRecord
    belongs_to :order
    belongs_to :product

    validates :quantity, numericality: { greater_than: 0 }
    validates :quantity, :price_mxn, :price_usd, presence: true
    validates :price_mxn, :price_usd, numericality: { greater_than: 0 }

    delegate :title, :subtitle, :cover, to: :product

    def price
      price_for_locale
    end

    private

    def price_for_locale(locale = I18n.locale)
      currency = Order::CURRENCIES[locale.to_sym]
      public_send("price_#{currency.downcase}")
    end
  end
end

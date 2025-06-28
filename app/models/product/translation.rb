# frozen_string_literal: true

class Product
  class Translation < ApplicationRecord
    belongs_to :product

    validates :locale, :title, :subtitle, :price, presence: true
    validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
    validates :price, presence: true, numericality: { greater_than: 0 }
  end
end

# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user

  has_many :items, class_name: 'Cart::Item', dependent: :destroy
  has_many :products, through: :items
end

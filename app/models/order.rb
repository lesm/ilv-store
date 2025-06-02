# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address

  has_many :items, class_name: 'Order::Item', dependent: :destroy
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :address

  validates :subtotal, :total, presence: true
end

# frozen_string_literal: true

class Order < ApplicationRecord
  enum :workflow_status, {
    created: 'created',
    in_transit: 'in_transit',
    canceled: 'canceled',
    delivered: 'delivered'
  }

  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy
  has_many :items, class_name: 'Order::Item', dependent: :destroy
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :address

  validates :subtotal, :total, presence: true
  validates :workflow_status, inclusion: { in: workflow_statuses.keys }
end

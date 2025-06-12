# frozen_string_literal: true

class Order < ApplicationRecord
  enum :status, {
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
  validates :status, inclusion: { in: statuses.keys }

  def short_id
    id.first(13)
  end
end

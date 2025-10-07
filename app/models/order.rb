# frozen_string_literal: true

class Order < ApplicationRecord
  self.ignored_columns = %w[label_price_snapshot]

  enum :workflow_status, {
    draft: 'draft',
    pending: 'pending',
    created: 'created',
    in_transit: 'in_transit',
    canceled: 'canceled',
    delivered: 'delivered'
  }, prefix: true

  enum :payment_status, {
    pending: 'pending',
    paid: 'paid',
    failed: 'failed'
  }, prefix: true

  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy
  has_many :items, class_name: 'Order::Item', dependent: :destroy
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :address

  validates :subtotal, :total, :label_price, presence: true
  validates :workflow_status, inclusion: { in: workflow_statuses.keys }
  validates :payment_status, inclusion: { in: payment_statuses.keys }

  after_commit :process_inventory_changes, on: :create

  private

  def process_inventory_changes
    items.each do
      Product.decrement_counter(:stock, it.product_id, by: it.quantity) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end

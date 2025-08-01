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

  after_commit :complete_order_processing, on: :create

  private

  def complete_order_processing
    process_inventory_changes
    send_order_confirmation_email
  end

  def process_inventory_changes
    items.each do
      Product.decrement_counter(:stock, it.product_id, by: it.quantity) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def send_order_confirmation_email
    OrderMailerJob.perform_later(id, :send_order_created)
  end
end

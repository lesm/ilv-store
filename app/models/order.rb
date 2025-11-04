# frozen_string_literal: true

class Order < ApplicationRecord
  self.ignored_columns += %w[label_price_snapshot]

  CURRENCIES = { es: 'MXN', en: 'USD' }.freeze

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
  has_many :stock_reservations, dependent: :destroy
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :address

  validates :subtotal, :total, :label_price, presence: true
  validates :workflow_status, inclusion: { in: workflow_statuses.keys }
  validates :payment_status, inclusion: { in: payment_statuses.keys }
  validates :stripe_session_id, uniqueness: true, allow_nil: true
  validates :tracking_number, exclusion: { in: [''], message: :blank }, allow_nil: true
  validates :carrier_name, exclusion: { in: [''], message: :blank }, allow_nil: true

  after_create :reserve_stock!

  delegate :email, to: :user, prefix: true, allow_nil: true

  def commit_stock_reservations!
    transaction do
      stock_reservations.includes(:product).status_active.find_each(&:commit!)
    end
  end

  def cancel_stock_reservations!
    transaction do
      stock_reservations.includes(:product).status_active.find_each(&:cancel!)
    end
  end

  def currency
    CURRENCIES[locale.to_sym]
  end

  private

  def reserve_stock!
    StockReservation.reserve_for_order(self)
  end
end

# frozen_string_literal: true

class AddPaymentStatusToOrder < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :payment_status, :string, null: false, default: 'pending'
  end
end

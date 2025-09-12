# frozen_string_literal: true

class AddStripeSessionIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :stripe_session_id, :string
    add_index :orders, :stripe_session_id, unique: true
  end
end

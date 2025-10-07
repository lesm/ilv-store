# frozen_string_literal: true

class AddLabelPriceDetailtsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :label_price, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :orders, :label_price_snapshot, :jsonb, default: {}, null: false
  end
end

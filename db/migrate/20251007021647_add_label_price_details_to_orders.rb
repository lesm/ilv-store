# frozen_string_literal: true

class AddLabelPriceDetailsToOrders < ActiveRecord::Migration[8.0]
  def up
    change_table :orders, bulk: true do |t|
      t.decimal :label_price, precision: 10, scale: 2, default: 0.0, null: false
      t.jsonb :label_price_snapshot, default: {}, null: false
    end
  end

  def down
    change_table :orders, bulk: true do |t|
      t.remove :label_price
      t.remove :label_price_snapshot
    end
  end
end

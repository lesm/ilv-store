# frozen_string_literal: true

class AddPriceSnapshotToCartItems < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_items, :price_snapshot, :decimal, precision: 10, scale: 2
  end
end

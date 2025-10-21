# frozen_string_literal: true

class RemovePriceFromCartItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :cart_items, :price, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end

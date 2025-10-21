# frozen_string_literal: true

class AddCurrencyPricesToOrderItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :order_items, :price, :price_mxn

    add_column :order_items, :price_usd, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end

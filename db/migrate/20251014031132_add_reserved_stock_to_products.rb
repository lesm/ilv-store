# frozen_string_literal: true

class AddReservedStockToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :reserved_stock, :integer, default: 0, null: false
  end
end

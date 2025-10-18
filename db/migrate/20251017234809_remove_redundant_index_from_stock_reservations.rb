# frozen_string_literal: true

class RemoveRedundantIndexFromStockReservations < ActiveRecord::Migration[8.0]
  def change
    remove_index :stock_reservations, :product_id
  end
end

# frozen_string_literal: true

class CreateStockReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_reservations, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, null: false
      t.datetime :reserved_until, null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :stock_reservations, :status
    add_index :stock_reservations, :reserved_until
    add_index :stock_reservations, %i[product_id status]
  end
end

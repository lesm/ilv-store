# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :address, null: false, foreign_key: true, type: :uuid
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end

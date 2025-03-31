# frozen_string_literal: true

class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :cart, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, null: false, default: 1
      t.boolean :out_of_stock, null: false, default: false

      t.timestamps
    end
  end
end

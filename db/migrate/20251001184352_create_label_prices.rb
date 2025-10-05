# frozen_string_literal: true

class CreateLabelPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :label_prices, id: :uuid do |t|
      t.string :product_type, null: false
      t.decimal :range_start, precision: 5, scale: 2, null: false
      t.decimal :range_end, precision: 5, scale: 2, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :unit, null: false

      t.timestamps
    end
  end
end

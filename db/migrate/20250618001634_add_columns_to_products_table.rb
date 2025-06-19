# frozen_string_literal: true

class AddColumnsToProductsTable < ActiveRecord::Migration[8.0]
  def change
    change_table :products, bulk: true do |t|
      t.rename :name, :original_title
      t.rename :price, :price_mx

      t.string :title_mx
      t.string :language
      t.string :language_zone
      t.string :edition_number
      t.string :pages_number
      t.string :internal_code
    end
  end
end

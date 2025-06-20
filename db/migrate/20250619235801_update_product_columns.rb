# frozen_string_literal: true

class UpdateProductColumns < ActiveRecord::Migration[8.0]
  def change
    change_table :products, bulk: true do |t|
      t.change_null :original_title, false
      t.change_null :title_mx, false
      t.change_null :language, false
      t.change_null :language_zone, false
      t.change_null :edition_number, false
      t.change_null :pages_number, false
      t.change_null :internal_code, false
      t.change_null :price_mx, false
      t.change_null :stock, false

      t.index :internal_code, unique: true
    end
  end
end

# frozen_string_literal: true

class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.index :name, unique: true
      t.index :code, unique: true

      t.timestamps
    end
  end
end

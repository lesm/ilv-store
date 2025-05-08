# frozen_string_literal: true

class CreateCountryStates < ActiveRecord::Migration[8.0]
  def change
    create_table :country_states, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.references :country, null: false, foreign_key: true, type: :uuid

      t.index %i[name country_id], unique: true
      t.index %i[code country_id], unique: true

      t.timestamps
    end
  end
end

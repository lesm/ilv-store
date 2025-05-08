# frozen_string_literal: true

class CreateCountryStateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :country_state_cities, id: :uuid do |t|
      t.string :name, null: false
      t.references :state, null: false, type: :uuid, foreign_key: { to_table: :country_states }

      t.index %i[name state_id], unique: true

      t.timestamps
    end
  end
end

# frozen_string_literal: true

class AddColumnsToAddresses < ActiveRecord::Migration[8.0]
  def change
    change_table :addresses, bulk: true do |t|
      t.remove :area_level1, type: :string
      t.remove :area_level2, type: :string
      t.references :state, null: false, type: :uuid, foreign_key: { to_table: :country_states }
      t.references :city, null: false, type: :uuid, foreign_key: { to_table: :country_state_cities }
      t.string :neighborhood
      t.string :full_name, null: false
      t.string :phone_number
    end
  end
end

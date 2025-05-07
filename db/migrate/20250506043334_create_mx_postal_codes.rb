# frozen_string_literal: true

class CreateMxPostalCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :mx_postal_codes, id: :uuid do |t|
      t.references :state, null: false, foreign_key: { to_table: :country_states }, type: :uuid
      t.references :city, null: false, foreign_key: { to_table: :country_state_cities }, type: :uuid
      t.string :postal_code
      t.string :neighborhood

      t.index [:postal_code, :neighborhood], unique: true

      t.timestamps
    end
  end
end

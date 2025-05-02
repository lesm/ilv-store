# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :country, null: false, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.string :area_level1
      t.string :area_level2
      t.string :street_level1
      t.string :street_level2
      t.string :postal_code, null: false
      t.string :reference

      t.timestamps
    end
  end
end

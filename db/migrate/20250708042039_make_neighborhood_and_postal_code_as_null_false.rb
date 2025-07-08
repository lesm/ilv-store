# frozen_string_literal: true

class MakeNeighborhoodAndPostalCodeAsNullFalse < ActiveRecord::Migration[8.0]
  def change
    change_table :mx_postal_codes, bulk: true do |t|
      t.change_null :neighborhood, false
      t.change_null :postal_code, false
    end
  end
end

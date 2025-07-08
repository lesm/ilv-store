# frozen_string_literal: true

class MakeStreetAndNumberColumnAsNullFalse < ActiveRecord::Migration[8.0]
  def change
    change_table :addresses do |t|
      t.change_null :street_and_number, false
    end
  end
end

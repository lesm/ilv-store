# frozen_string_literal: true

class AddColumnsToAddresses < ActiveRecord::Migration[8.0]
  def up
    remove_column :addresses, :area_level1
    remove_column :addresses, :area_level2

    add_reference :addresses, :state, null: false, type: :uuid, foreign_key: { to_table: :country_states }
    add_reference :addresses, :city, null: false, type: :uuid, foreign_key: { to_table: :country_state_cities }
    add_column :addresses, :neighborhood, :string
  end

  def down
    remove_reference :addresses, :state, type: :uuid
    remove_reference :addresses, :city, type: :uuid
    remove_column :addresses, :neighborhood

    add_column :addresses, :area_level1, :string
    add_column :addresses, :area_level2, :string
  end
end

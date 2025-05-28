# frozen_string_literal: true

class ChangeAddressColumns < ActiveRecord::Migration[8.0]
  def up
    change_table :addresses, bulk: true do |t|
      t.remove :street_level2, type: :string
      t.remove :type, type: :string
      t.rename :street_level1, :street_and_number
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot revert the changes made to the addresses table'
  end
end

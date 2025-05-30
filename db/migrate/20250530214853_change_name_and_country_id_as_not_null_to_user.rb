# frozen_string_literal: true

class ChangeNameAndCountryIdAsNotNullToUser < ActiveRecord::Migration[8.0]
  def up
    change_table :users, bulk: true do |t|
      t.change :name, :string, null: false
      t.change :country_id, :uuid, null: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot revert the changes made to the users table'
  end
end

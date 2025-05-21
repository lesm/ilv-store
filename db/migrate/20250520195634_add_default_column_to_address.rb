# frozen_string_literal: true

class AddDefaultColumnToAddress < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :default, :boolean, default: false, null: false
    add_index :addresses, %i[user_id default], unique: true, where: '("default" = true)'
  end
end

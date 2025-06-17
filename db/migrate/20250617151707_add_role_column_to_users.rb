# frozen_string_literal: true

class AddRoleColumnToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, default: 'customer', null: false
  end
end

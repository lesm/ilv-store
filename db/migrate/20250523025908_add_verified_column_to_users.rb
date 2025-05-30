# frozen_string_literal: true

class AddVerifiedColumnToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verified, :boolean, default: false, null: false
  end
end

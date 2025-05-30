# frozen_string_literal: true

class AddNameAndUserIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_reference :users, :country, type: :uuid, foreign_key: true
  end
end

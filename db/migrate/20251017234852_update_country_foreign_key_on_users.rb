# frozen_string_literal: true

class UpdateCountryForeignKeyOnUsers < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :users, :countries
    add_foreign_key :users, :countries, on_delete: :restrict
  end
end

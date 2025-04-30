# frozen_string_literal: true

class AddThemePreferenceColumnToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme_preference, :string, default: 'light', null: false
  end
end

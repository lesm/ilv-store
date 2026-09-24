# frozen_string_literal: true

class AddPublishedToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :published, :boolean, default: true, null: false
    add_index :products, :published
  end
end

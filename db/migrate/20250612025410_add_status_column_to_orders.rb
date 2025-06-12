# frozen_string_literal: true

class AddStatusColumnToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :status, :string, null: false, default: 'created'
    add_index :orders, :status
  end
end

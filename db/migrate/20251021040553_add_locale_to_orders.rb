# frozen_string_literal: true

class AddLocaleToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :locale, :string, null: false, default: 'es'
  end
end

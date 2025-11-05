# frozen_string_literal: true

class AddRequiresInvoiceToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :requires_invoice, :boolean, default: false, null: false
  end
end

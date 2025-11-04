# frozen_string_literal: true

class AddTrackingNumberAndCarrierNameToOrders < ActiveRecord::Migration[8.0]
  def change
    change_table :orders, bulk: true do |t|
      t.string :tracking_number
      t.string :carrier_name
    end

    add_index :orders, :tracking_number
  end
end

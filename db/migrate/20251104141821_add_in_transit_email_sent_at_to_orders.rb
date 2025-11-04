# frozen_string_literal: true

class AddInTransitEmailSentAtToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :in_transit_email_sent_at, :datetime
  end
end

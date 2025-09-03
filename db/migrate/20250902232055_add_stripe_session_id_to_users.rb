# frozen_string_literal: true

class AddStripeSessionIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_session_id, :string
    add_index :users, :stripe_session_id, unique: true
  end
end

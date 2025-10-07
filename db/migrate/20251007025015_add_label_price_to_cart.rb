# frozen_string_literal: true

class AddLabelPriceToCart < ActiveRecord::Migration[8.0]
  def change
    add_reference :carts, :label_price, null: true, foreign_key: true, type: :uuid
  end
end

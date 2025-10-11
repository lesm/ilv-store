# frozen_string_literal: true

class AddPriceColumnToCartItem < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_items, :price, :decimal, precision: 10, scale: 2, null: false, default: 0.0

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE cart_items
          SET price = products.price
          FROM products
          WHERE cart_items.product_id = products.id;
        SQL
      end

      dir.down {} # rubocop:disable Lint/EmptyBlock
    end
  end
end

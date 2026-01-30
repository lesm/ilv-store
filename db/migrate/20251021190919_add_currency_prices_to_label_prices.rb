# frozen_string_literal: true

class AddCurrencyPricesToLabelPrices < ActiveRecord::Migration[8.0]
  def change
    rename_column :label_prices, :price, :price_mxn

    add_column :label_prices, :price_usd, :decimal, precision: 10, scale: 2

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE label_prices SET price_usd = 0;
        SQL
      end
    end

    change_column_null :label_prices, :price_usd, false
  end
end

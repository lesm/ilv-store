# frozen_string_literal: true

class AddMissingNumericalityCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :product_translations, 'price > 0', name: 'product_translations_price_positive'

    add_check_constraint :order_items, 'quantity > 0', name: 'order_items_quantity_positive'
    add_check_constraint :order_items, 'price_mxn > 0', name: 'order_items_price_mxn_positive'
    add_check_constraint :order_items, 'price_usd > 0', name: 'order_items_price_usd_positive'

    add_check_constraint :cart_items, 'quantity > 0', name: 'cart_items_quantity_positive'

    add_check_constraint :stock_reservations, 'quantity > 0', name: 'stock_reservations_quantity_positive'

    add_check_constraint :products, 'stock >= 0', name: 'products_stock_non_negative'
    add_check_constraint :products, 'reserved_stock >= 0', name: 'products_reserved_stock_non_negative'

    add_check_constraint :label_prices, 'range_start >= 0', name: 'label_prices_range_start_non_negative'
    add_check_constraint :label_prices, 'range_end >= 0', name: 'label_prices_range_end_non_negative'
    add_check_constraint :label_prices, 'price_mxn > 0', name: 'label_prices_price_mxn_positive'
    add_check_constraint :label_prices, 'price_usd > 0', name: 'label_prices_price_usd_positive'
  end
end

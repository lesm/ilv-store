# frozen_string_literal: true

class CreateProductTranslations < ActiveRecord::Migration[8.0]
  def up
    create_table :product_translations, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.string :locale, null: false
      t.string :title, null: false
      t.string :subtitle, null: false
      t.decimal :price, null: false, precision: 10, scale: 2, default: 0.0
      t.index %i[product_id locale], unique: true

      t.timestamps
    end

    execute <<-SQL.squish
      INSERT INTO product_translations (product_id, locale, title, subtitle, price, created_at, updated_at)
      SELECT id, 'es', title_mx, original_title, price_mx, created_at, updated_at
      FROM products
      WHERE productable_type = 'Book';
    SQL

    change_table :products, bulk: true do |t|
      t.remove :title_mx
      t.remove :original_title
      t.remove :price_mx
    end
  end

  def down
    change_table :products, bulk: true do |t|
      t.string :title_mx
      t.string :original_title
      t.decimal :price_mx, precision: 10, scale: 2, default: 0.0
    end

    execute <<-SQL.squish
      UPDATE products
        SET title_mx = pt.title,
            original_title = pt.subtitle,
            price_mx = pt.price
      FROM product_translations pt
      WHERE products.id = pt.product_id
    SQL

    change_table :products, bulk: true do |t|
      t.change_null :title_mx, false
      t.change_null :original_title, false
      t.change_null :price_mx, false
    end

    drop_table :product_translations
  end
end

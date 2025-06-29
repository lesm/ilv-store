# frozen_string_literal: true

class MakeProductsAsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    change_table :products do |t|
      t.references :productable, polymorphic: true, type: :uuid, index: true
    end

    execute <<-SQL.squish
      UPDATE products
        SET productable_id = books.id, productable_type = 'Book'
      FROM books
      WHERE products.internal_code = books.internal_code;
    SQL

    change_table :products, bulk: true do |t|
      t.remove :language
      t.remove :language_zone
      t.remove :pages_number
      t.remove :edition_number
      t.remove :internal_code
      t.change_null :productable_id, false
      t.change_null :productable_type, false
    end
  end

  def down
    change_table :products, bulk: true do |t|
      t.string :language
      t.string :language_zone
      t.string :edition_number
      t.string :pages_number
      t.string :internal_code
    end

    execute <<-SQL.squish
      UPDATE products
        SET language = books.language,
            language_zone = books.language_zone,
            edition_number = books.edition_number,
            pages_number = books.pages_number,
            internal_code = books.internal_code
      FROM books
      WHERE products.productable_id = books.id
    SQL

    change_table :products, bulk: true do |t|
      t.change_null :language, false
      t.change_null :language_zone, false
      t.change_null :pages_number, false
      t.change_null :edition_number, false
      t.change_null :internal_code, false
      t.index :internal_code, unique: true
      t.remove_references :productable, polymorphic: true, type: :uuid
    end
  end
end

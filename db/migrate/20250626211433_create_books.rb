# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[8.0]
  def up
    create_table :books, id: :uuid do |t|
      t.string :language
      t.string :language_zone
      t.string :pages_number
      t.string :edition_number
      t.string :internal_code

      t.timestamps
    end

    execute <<-SQL.squish
      INSERT INTO books (id, language, language_zone, edition_number, pages_number,
                        internal_code, created_at, updated_at)
      SELECT gen_random_uuid(), language, language_zone, edition_number,
             pages_number, internal_code, created_at, updated_at
      FROM products
    SQL

    change_table :books, bulk: true do |t|
      t.change_null :language, false
      t.change_null :language_zone, false
      t.change_null :pages_number, false
      t.change_null :edition_number, false
      t.change_null :internal_code, false
      t.index :internal_code, unique: true
    end
  end

  def down
    drop_table :books
  end
end

# frozen_string_literal: true

class MakeAddressAsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    change_table :addresses do |t|
      t.remove_index %i[user_id default]
      t.references :addressable, polymorphic: true, type: :uuid
      t.index %i[addressable_id default], unique: true, where: '("default" = true)'
    end

    execute <<~SQL.squish
      UPDATE addresses
      SET addressable_id = users.id, addressable_type = 'User'
      FROM users
      WHERE addresses.user_id = users.id;
    SQL

    execute <<~SQL.squish
      UPDATE addresses
      SET addressable_id = orders.id, addressable_type = 'Order'
      FROM orders
      WHERE addresses.id = orders.address_id;
    SQL

    change_table :addresses, bulk: true do |t|
      t.remove :user_id, type: :uuid
      t.change_null :addressable_id, false
      t.change_null :addressable_type, false
    end

    change_table :orders, bulk: true do |t|
      t.remove_references :address, type: :uuid
    end
  end

  def down # rubocop:disable Metrics/AbcSize
    change_table :orders, bulk: true do |t|
      t.references :address, type: :uuid
    end

    change_table :addresses, bulk: true do |t|
      t.uuid :user_id, type: :uuid
      t.index %i[user_id default], unique: true, where: '("default" = true)'
      t.index :user_id
    end

    execute <<~SQL.squish
      UPDATE addresses
      SET user_id = users.id
      FROM users
      WHERE addresses.addressable_id = users.id;
    SQL

    execute <<~SQL.squish
      UPDATE addresses
      SET user_id = orders.user_id
      FROM orders
      WHERE addresses.addressable_id = orders.id;
    SQL

    execute <<~SQL.squish
      UPDATE orders
      SET address_id = addresses.id
      FROM addresses
      WHERE addresses.addressable_id = orders.id;
    SQL

    change_table :addresses, bulk: true do |t|
      t.remove_index %i[addressable_id default]
      t.remove_references :addressable, polymorphic: true, type: :uuid
      t.change_null :user_id, false
      t.foreign_key :users, type: :uuid
    end

    change_table :orders, bulk: true do |t|
      t.change_null :address_id, false
      t.foreign_key :addresses, type: :uuid
    end
  end
end

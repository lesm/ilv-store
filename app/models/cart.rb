# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user

  has_many :items, class_name: 'Cart::Item', dependent: :destroy
  has_many :products, through: :items

  after_update_commit :broadcast_total_items

  private

  def broadcast_total_items
    broadcast_update_to(self, target: "total_items_cart_#{id}", partial: 'carts/total_items')
    broadcast_update_to(self, target: "total_items_drawer_cart_#{id}", partial: 'carts/total_items_drawer')
  end
end

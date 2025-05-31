# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address

  validates :subtotal, :total, presence: true
end

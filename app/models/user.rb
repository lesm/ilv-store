# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :addresses, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true
  validates :email_address, uniqueness: true
end

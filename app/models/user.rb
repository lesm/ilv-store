# frozen_string_literal: true

class User < ApplicationRecord
  include EmailVerification

  has_secure_password

  belongs_to :country

  has_one :cart, dependent: :destroy
  has_one :default_address, -> { where(default: true) },
          class_name: 'Address', dependent: :destroy, inverse_of: :user

  has_many :sessions, dependent: :destroy
  has_many :addresses, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: true
end

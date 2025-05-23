# frozen_string_literal: true

module EmailVerification
  extend ActiveSupport::Concern

  included do
    generates_token_for :email_verification_token, expires_in: 1.day
  end

  class_methods do
    def find_by_email_verification_token!(token)
      find_by_token_for! :email_verification_token, token
    end
  end

  def email_verification_token
    generate_token_for(:email_verification_token)
  end
end

# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/account_mailer
class AccountMailerPreview < ActionMailer::Preview
  def reset_password
    AccountMailer.with(user:).reset_password if user.present?
  end

  def verify_email
    AccountMailer.with(user:).verify_email if user.present?
  end

  private

  def user
    @user ||= User.first
  end
end

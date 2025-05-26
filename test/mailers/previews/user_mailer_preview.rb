# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def send_email_verification
    UserMailer.with(user: User.first).send_email_verification
  end
end

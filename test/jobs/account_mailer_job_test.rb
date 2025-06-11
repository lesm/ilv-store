# frozen_string_literal: true

require 'test_helper'

class AccountMailerJobTest < ActiveJob::TestCase
  let(:user) { create(:user) }

  test 'sends the verify email' do
    EmailService.expects(:send_verify_email).with(user: user)

    perform_enqueued_jobs do
      AccountMailerJob.perform_later(user.id, :send_verify_email)
    end
  end
end

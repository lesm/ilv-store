# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_normalize_email_address
    user = build(:user, email_address: ' maIL@mail.com')

    assert_equal 'mail@mail.com', user.email_address
  end

  def test_validate_email_address_presence
    user = build(:user, email_address: nil)

    assert user.invalid?
  end

  def test_validate_email_address_uniqueness
    create(:user, email_address: 'mail@mail.com')
    user = build(:user, email_address: 'mail@mail.com')

    assert user.invalid?
    assert_includes user.errors.details[:email_address], error: :taken, value: 'mail@mail.com'
  end
end

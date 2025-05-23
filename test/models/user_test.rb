# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  let(:user) { build(:user) }

  test 'builds a valid user' do
    assert user.valid?
  end

  describe '#email' do
    test 'normalizes the email address' do
      user.email = ' maIL@mail.com'

      assert_equal 'mail@mail.com', user.email
    end

    test 'requires presence' do
      user.email = nil

      assert user.invalid?
    end

    test 'requires uniqueness' do
      create(:user, email: 'mail@mail.com')
      user.email = 'mail@mail.com'

      assert user.invalid?
      assert_includes user.errors.details[:email], error: :taken, value: 'mail@mail.com'
    end
  end

  test 'requires a password' do
    user.password = nil

    assert user.invalid?
  end
end

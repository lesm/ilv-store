# frozen_string_literal: true

require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  let(:user) { create(:user, email: 'test@mail.com') }
  let(:order) { create(:order, :created, user:) }

  test '.created' do
    email = OrderMailer.with(order:).created

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal 'Hemos recibido tu pedido', email.subject
    assert_match(/Gracias por tu compra/, email.body.to_s)
  end
end

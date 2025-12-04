# frozen_string_literal: true

require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  let(:user) { create(:user, email: 'test@mail.com') }
  let(:order) { create(:order, :order_created, user:) }

  test '.created' do
    email = OrderMailer.with(order:).created

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal ['mail@mail.com'], email.cc
    assert_equal 'Hemos recibido tu pedido', email.subject
    assert_match(/Gracias por tu compra/, email.body.to_s)
  end

  test '.in_transit' do
    email = OrderMailer.with(order:).in_transit

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['mail@mail.com'], email.from
    assert_equal ['test@mail.com'], email.to
    assert_equal 'Tu pedido está en camino', email.subject
    assert_match(/Tu pedido está en tránsito y llegará pronto/, email.body.to_s)
  end
end

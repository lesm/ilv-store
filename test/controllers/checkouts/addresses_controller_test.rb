# frozen_string_literal: true

require 'test_helper'

module Checkouts
  class AddressesControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :with_default_address) }

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returnts a successful response' do
        get checkout_addresses_url
        assert_response :success
      end
    end

    describe '#PUT update' do
      let(:address) { create(:mexican_address, user:) }

      test 'updates the default address' do
        put(checkout_address_url(id: address.id, format: :turbo_stream), params: {})
        assert_response :success
        assert_equal address.reload.default, true
      end

      test 'renders the correct partial' do
        put(checkout_address_url(id: address.id, format: :turbo_stream), params: {})

        assert_turbo_stream action: :replace, target: 'checkout_address'
      end
    end
  end
end

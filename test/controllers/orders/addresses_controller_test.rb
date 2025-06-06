# frozen_string_literal: true

require 'test_helper'

module Orders
  class AddressesControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :with_default_address) }

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns a successful response' do
        get order_addresses_url
        assert_response :success
      end
    end

    describe '#PUT update' do
      let(:address) { create(:address, :mx, addressable: user) }

      test 'updates the default address' do
        put(order_address_url(id: address.id, format: :turbo_stream), params: {})
        assert_response :success
        assert_equal address.reload.default, true
      end

      test 'renders the correct partial' do
        put(order_address_url(id: address.id, format: :turbo_stream), params: {})

        assert_turbo_stream action: :replace, target: 'orders-address'
      end
    end
  end
end

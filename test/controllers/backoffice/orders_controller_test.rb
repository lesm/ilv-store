# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class OrdersControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :admin) }

    before do
      authenticate_as(user)
    end

    describe '#GET index' do
      test 'returns success response' do
        create_list(:order, 3, :order_created)

        get backoffice_orders_url
        assert_response :success
      end
    end
  end
end

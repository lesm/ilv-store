# frozen_string_literal: true

require 'test_helper'

module Backoffice
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user) }

    before do
      authenticate_as(user)
    end

    describe '#index' do
      test 'returns success response' do
        get backoffice_products_url

        assert_response :success
      end
    end
  end
end

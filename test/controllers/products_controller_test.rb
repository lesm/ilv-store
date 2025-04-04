# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  describe '#index' do
    test 'returns success response' do
      get products_url

      assert_response :success
    end
  end
end

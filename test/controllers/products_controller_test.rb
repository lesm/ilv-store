# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  describe '#index' do
    test 'returns success response' do
      create_list(:product, 3)

      get products_url

      assert_response :success
    end
  end

  describe '#show' do
    test 'returns success response' do
      get product_url(id: create(:product).id, turbo_frame: 'drawer')

      assert_response :success
    end
  end
end

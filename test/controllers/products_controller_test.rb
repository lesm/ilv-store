# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  describe '#index' do
    test 'returns success response' do
      create_list(:product, 3)

      get products_url

      assert_response :success
    end

    test 'paginates products with 8 items per page' do
      create_list(:product, 10)

      get products_url

      assert_response :success
      assert_select '#products-list .flex.flex-col.h-full', count: 8
    end

    test 'returns turbo_stream response for pagination' do
      create_list(:product, 10)

      get products_url(page: 2), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      assert_response :success
      assert_equal 'text/vnd.turbo-stream.html', response.media_type
    end

    test 'includes pagination link when there are more pages' do
      create_list(:product, 10)

      get products_url

      assert_response :success
      assert_select '#pagination a[rel="next"]'
    end

    test 'does not include pagination link on last page' do
      create_list(:product, 10)

      get products_url(page: 2)

      assert_response :success
      assert_select '#pagination a[rel="next"]', count: 0
    end
  end

  describe '#show' do
    test 'returns success response' do
      get product_url(id: create(:product).id, turbo_frame: 'drawer')

      assert_response :success
    end
  end
end

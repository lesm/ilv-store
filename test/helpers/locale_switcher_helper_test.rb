# frozen_string_literal: true

require 'test_helper'

class LocaleSwitcherHelperTest < ActionView::TestCase
  describe '#locale_switcher_path' do
    test 'prefixes the path with the target locale, dropping the current one' do
      request.stubs(path: '/es/products', query_parameters: {})

      assert_equal '/en/products', locale_switcher_path('en')
    end

    test 'preserves other query params but drops the locale param' do
      request.stubs(path: '/en/products', query_parameters: { 'category' => 'books', 'locale' => 'en' })

      assert_equal '/es/products?category=books', locale_switcher_path('es')
    end

    test 'uses a locale query param for the root path' do
      request.stubs(path: '/', query_parameters: {})

      assert_equal '/?locale=es', locale_switcher_path('es')
    end

    test 'works when the current path has no locale prefix' do
      request.stubs(path: '/products', query_parameters: {})

      assert_equal '/en/products', locale_switcher_path('en')
    end
  end
end

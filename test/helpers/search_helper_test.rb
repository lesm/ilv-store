# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  describe '#highlighted_text' do
    test 'returns original text when no highlights present' do
      product = create(:product)

      result = highlighted_text(product, :title)

      assert_equal product.title, result
    end

    test 'returns highlighted text when highlights are present' do
      product = create(:product)
      original_title = product.title
      snippet = "#{original_title.split.first} <mark class=\"search-highlight\">#{original_title.split.last}</mark>"
      highlights = [
        {
          'field' => 'title_es',
          'snippet' => snippet
        }
      ]
      product.instance_variable_set(:@search_highlights, highlights)

      result = highlighted_text(product, :title)

      assert_includes result, '<mark class="search-highlight">'
      assert_includes result, '</mark>'
    end

    test 'returns original text when field does not match' do
      product = create(:product)
      highlights = [
        {
          'field' => 'title_es',
          'snippet' => 'Test <mark class="search-highlight">Product</mark>'
        }
      ]
      product.instance_variable_set(:@search_highlights, highlights)

      result = highlighted_text(product, :subtitle)

      assert_equal product.subtitle, result
    end

    test 'works with different locales' do
      I18n.with_locale(:en) do
        product = create(:product,
                         translations: [
                           build(:product_translation, locale: 'en', title: 'English Title'),
                           build(:product_translation, locale: 'es', title: 'Título Español')
                         ])
        highlights = [
          {
            'field' => 'title_en',
            'snippet' => 'English <mark class="search-highlight">Title</mark>'
          }
        ]
        product.instance_variable_set(:@search_highlights, highlights)

        result = highlighted_text(product, :title)

        assert_equal 'English <mark class="search-highlight">Title</mark>', result
      end
    end

    test 'returns original text when snippet is nil' do
      product = create(:product)
      highlights = [
        {
          'field' => 'title_es',
          'snippet' => nil
        }
      ]
      product.instance_variable_set(:@search_highlights, highlights)

      result = highlighted_text(product, :title)

      assert_equal product.title, result
    end
  end
end

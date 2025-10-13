# frozen_string_literal: true

module SearchHelper
  def highlighted_text(product, field)
    highlights = product.instance_variable_get(:@search_highlights)

    return product.send(field) unless highlights

    locale = I18n.locale
    field_name = "#{field}_#{locale}"

    highlight = highlights.find { |h| h['field'] == field_name }

    if highlight&.dig('snippet')
      highlight['snippet'].html_safe # rubocop:disable Rails/OutputSafety
    else
      product.send(field)
    end
  end
end

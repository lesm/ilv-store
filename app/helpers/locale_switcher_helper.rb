# frozen_string_literal: true

module LocaleSwitcherHelper
  # Mirrors navbar/locale_switcher_controller.js#buildLocaleUrl so the server-rendered
  # href is already a real, working link (no JS required), and the Stimulus controller
  # only needs to keep it in sync when the URL changes client-side (e.g. search filters).
  def locale_switcher_path(locale)
    base_path = path_without_locale(request.path)
    query = request.query_parameters.except('locale')

    if base_path.blank?
      "/?#{query.merge('locale' => locale).to_query}"
    else
      path = "/#{locale}/#{base_path}"
      query.blank? ? path : "#{path}?#{query.to_query}"
    end
  end

  private

  def path_without_locale(path)
    segments = path.split('/').reject(&:empty?)
    segments.shift if I18n.available_locales.map(&:to_s).include?(segments.first)
    segments.join('/')
  end
end

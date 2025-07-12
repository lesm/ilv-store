# frozen_string_literal: true

module ApplicationHelper
  def theme_preference
    current_user&.theme_preference || 'light'
  end

  def cover_image(cover, variant: :small)
    cover.variant(variant) || 'default-cover.svg'
  end
end

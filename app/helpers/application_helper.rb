# frozen_string_literal: true

module ApplicationHelper
  def theme_preference
    current_user&.theme_preference || 'light'
  end

  def cover_image(cover)
    cover.attached? ? cover : 'default-cover.svg'
  end
end

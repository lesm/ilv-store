# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def theme_preference
    current_user&.theme_preference || 'light'
  end

  def cover_image(cover, variant: :small)
    cover.variant(variant) || 'default-cover.svg'
  end

  def pagy_next_link(pagy)
    return unless pagy.next

    link_to pagy_url_for(pagy, pagy.next), rel: 'next', aria_label: 'Next page' do
      # No visible content needed, but we keep the link for JS to find
      ''
    end
  end
end

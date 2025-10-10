# frozen_string_literal: true

class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    # Use joins instead of includes to avoid DISTINCT issues with Pagy
    products_query = Product.joins(:translations)
                            .where(translations: { locale: I18n.locale })
                            .includes(:translations, cover_attachment: :blob)

    @pagy, @products = pagy(products_query, limit: 8)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    request.variant = :drawer
    @product = Product.includes(:translations, :productable).find(params[:id])
  end
end

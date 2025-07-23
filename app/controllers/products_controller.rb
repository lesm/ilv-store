# frozen_string_literal: true

class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    @products = Product.includes(:translations, cover_attachment: :blob)
                       .where(translations: { locale: I18n.locale })
  end

  def show
    request.variant = :drawer
    @product = Product.includes(:translations, :productable).find(params[:id])
  end
end

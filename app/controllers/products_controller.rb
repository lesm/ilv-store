# frozen_string_literal: true

class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    @products = Product.includes(:translation).all
  end

  def show
    request.variant = :drawer
    @product = Product.includes(:translation, :productable).find(params[:id])
  end
end

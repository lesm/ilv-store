# frozen_string_literal: true

module Backoffice
  class ProductsController < BaseController
    def index
      @products = Product.all
    end

    def new
      request.variant = :drawer
      @product = Product.new
    end

    def edit
      request.variant = :drawer
      @product = Product.find(params[:id])
    end

    def create # rubocop:disable Metrics/AbcSize
      @product = Product.new(product_params)

      if @product.save
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_products_path)
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    def update # rubocop:disable Metrics/AbcSize
      @product = Product.find(params[:id])

      if @product.update(product_params)
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_products_path)
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    private

    def product_params
      params.expect(
        product: %i[
          internal_code original_title title_mx language
          language_zone edition_number pages_number price_mx stock
        ]
      )
    end
  end
end

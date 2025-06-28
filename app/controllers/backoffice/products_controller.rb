# frozen_string_literal: true

module Backoffice
  class ProductsController < BaseController
    def index
      @products = Product.includes(:translation, :productable)
                         .where(productable_type: params[:type].to_s.capitalize)
    end

    def new
      request.variant = :drawer
      @product = Book.new(product: Product.new(translation: Product::Translation.new))
    end

    def edit
      request.variant = :drawer
      @product = Book.find(params[:id])
    end

    def create # rubocop:disable Metrics/AbcSize
      @product = Book.new(product_params)

      if @product.save
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_products_path)
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    def update # rubocop:disable Metrics/AbcSize
      @product = Book.find(params[:id])

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
        book: [
          :internal_code, :language, :language_zone, :edition_number, :pages_number,
          { product_attributes: [:id, :stock, { translation_attributes: %i[id title subtitle locale price] }] }
        ]
      )
    end
  end
end

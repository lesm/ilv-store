# frozen_string_literal: true

module Backoffice
  class ProductsController < BaseController
    def index
      @products = Product.includes(:translation, :productable)
                         .where(productable_type: product_type.capitalize)
    end

    def new
      request.variant = :drawer

      @product = product_klass.new(
        product: Product.new(translation: Product::Translation.new(locale: 'es'))
      )
    end

    def edit
      request.variant = :drawer
      @product = product_klass.includes(product: [:translation, { cover_attachment: :blob }]).find(params[:id])
    end

    def create # rubocop:disable Metrics/AbcSize
      @product = product_klass.new(product_params)

      if @product.save
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_products_path)
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    def update # rubocop:disable Metrics/AbcSize
      @product = product_klass.find(params[:id])

      if @product.update(product_params)
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_products_path)
      else
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    private

    def product_type
      (['book'] & [params[:type]]).first || 'book'
    end

    def product_klass
      product_type.classify.constantize
    end

    def product_params
      params.expect(
        book: [
          :internal_code, :language, :language_zone, :edition_number, :pages_number,
          :cover_color, :dimensions, :weight_grams,
          { product_attributes: [:id, :stock, :cover, { translation_attributes: %i[id title subtitle locale price] }] }
        ]
      )
    end
  end
end

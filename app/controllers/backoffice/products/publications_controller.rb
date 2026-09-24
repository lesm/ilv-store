# frozen_string_literal: true

module Backoffice
  module Products
    class PublicationsController < BaseController
      before_action :set_product

      def create
        @product.publish!
        render_card_with_notice
      end

      def destroy
        @product.unpublish!
        render_card_with_notice
      end

      private

      def set_product
        @product = Product.includes(:translations, :productable).find(params.expect(:product_id))
      end

      def render_card_with_notice
        flash.now[:notice] = t('.success')

        render turbo_stream: [
          turbo_stream.replace(@product, partial: "backoffice/products/#{product_type}_card",
                                         locals: { product: @product, product_type.to_sym => @product.productable }),
          turbo_stream.append(:flash, partial: 'shared/flash')
        ]
      end

      def product_type = @product.productable_type.underscore
    end
  end
end

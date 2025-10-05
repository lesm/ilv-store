# frozen_string_literal: true

module Backoffice
  class LabelPricesController < BaseController
    def index
      @label_prices = LabelPrice.all
    end

    def new
      request.variant = :drawer

      @label_price = LabelPrice.new(product_type: 'Book', unit: 'kg')
    end

    def edit
      request.variant = :drawer
      @label_price = LabelPrice.find(params[:id])
    end

    def create
      @label_price = LabelPrice.new(label_price_params)

      result = @label_price.save
      handle_result(result, @label_price)
    end

    def update
      @label_price = LabelPrice.find(params[:id])

      result = @label_price.update(label_price_params)
      handle_result(result, @label_price)
    end

    private

    def handle_result(result, resource)
      if result
        flash[:notice] = t('.success')
        render turbo_stream: turbo_stream.action(:redirect, backoffice_label_prices_path)
      else
        flash.now[:alert] = resource.errors.full_messages.to_sentence
        render turbo_stream: turbo_stream.append(:flash, partial: 'shared/flash')
      end
    end

    def label_price_params
      params.expect(label_price: %i[product_type range_start range_end price unit])
    end
  end
end

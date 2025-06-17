# frozen_string_literal: true

module Backoffice
  class ProductsController < BaseController
    def index
      @products = Product.all
    end
  end
end

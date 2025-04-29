# frozen_string_literal: true

class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    resume_session

    @products = Product.all
  end
end

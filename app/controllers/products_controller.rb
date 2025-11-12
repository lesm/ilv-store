# frozen_string_literal: true

class ProductsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    @query = params[:q].to_s.strip
    @is_search = params.key?(:q)
    @pagy, @products = search_or_list_products
    @total_results = @pagy.count if @query.present?
  end

  def show
    request.variant = :drawer
    @product = Product.includes(:translations, :productable).find(params[:id])
  end

  private

  def search_or_list_products
    @query.present? ? search_products : list_products
  end

  def search_products
    result = Product.search(@query, per_page: products_per_page, page: current_page)

    products = result['hits'].map do |hit|
      product = Product.find(hit['document']['id'])
      product.instance_variable_set(:@search_highlights, hit['highlights'])
      product
    end

    pagy = Pagy.new(count: result['found'], page: current_page, limit: products_per_page)
    [pagy, products]
  end

  def list_products
    products_query = Product.joins(:translations)
                            .where(translations: { locale: I18n.locale })
                            .includes(:translations, cover_attachment: :blob)
                            .order(created_at: :desc)

    pagy(products_query, limit: products_per_page)
  end

  def products_per_page
    8
  end

  def current_page
    params[:page] || 1
  end
end

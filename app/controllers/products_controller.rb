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
    @product = Product.published.includes(:translations, :productable).find(params.expect(:id))
  end

  private

  def search_or_list_products
    @query.present? ? search_products : list_products
  end

  def search_products
    result = Product.search(@query, per_page: products_per_page, page: current_page, filter_by: 'published:true')
    products = published_products_from(result['hits'])

    pagy, = pagy(:offset, products, page: current_page, limit: products_per_page, count: result['found'])
    [pagy, products]
  end

  # Loads hits from the DB keeping Typesense's order, and drops any product
  # unpublished since it was indexed.
  def published_products_from(hits)
    products = Product.published
                      .includes(:translations, cover_attachment: :blob)
                      .where(id: hits.map { it['document']['id'] })
                      .index_by(&:id)

    hits.filter_map do |hit|
      product = products[hit['document']['id']]
      product&.instance_variable_set(:@search_highlights, hit['highlights'])
      product
    end
  end

  def list_products
    products_query = Product.published
                            .joins(:translations)
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

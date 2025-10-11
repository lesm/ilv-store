# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_save :index_in_typesense
    after_destroy :remove_from_typesense
  end

  class_methods do # rubocop:disable Metrics/BlockLength
    def typesense_client
      TYPESENSE_CLIENT
    end

    def typesense_collection_name
      "#{Rails.env}_#{table_name}"
    end

    def create_typesense_collection
      typesense_client.collections.create(typesense_schema)
    rescue Typesense::Error::ObjectAlreadyExists
      Rails.logger.info "Collection #{typesense_collection_name} already exists"
    end

    def reindex_all
      create_typesense_collection

      find_each(&:index_in_typesense)
    end

    def search(query, options = {}) # rubocop:disable Metrics/MethodLength
      search_params = {
        q: query,
        query_by: typesense_query_by,
        per_page: options[:per_page] || 20,
        page: options[:page] || 1,
        highlight_fields: typesense_query_by,
        highlight_full_fields: typesense_query_by,
        highlight_start_tag: '<mark class="search-highlight">',
        highlight_end_tag: '</mark>'
      }.merge(options)

      typesense_client.collections[typesense_collection_name].documents.search(search_params)
    end
  end

  def index_in_typesense # rubocop:disable Metrics/AbcSize
    self.class.typesense_client.collections[self.class.typesense_collection_name]
        .documents.upsert(typesense_document) # rubocop:disable Rails/SkipsModelValidations
  rescue Typesense::Error::ObjectNotFound
    self.class.create_typesense_collection
    retry
  rescue StandardError => e
    Rails.logger.error "Failed to index #{self.class.name} #{id}: #{e.message}"
  end

  def remove_from_typesense # rubocop:disable Metrics/AbcSize
    self.class.typesense_client.collections[self.class.typesense_collection_name]
        .documents[id.to_s].delete
  rescue StandardError => e
    Rails.logger.error "Failed to remove #{self.class.name} #{id} from Typesense: #{e.message}"
  end
end

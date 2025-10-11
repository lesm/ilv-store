# frozen_string_literal: true

namespace :typesense do
  desc 'Reindex all products in Typesense'
  task reindex: :environment do
    puts 'Starting Typesense reindexing...'

    Product.reindex_all

    puts "Successfully indexed #{Product.count} products"
  end

  desc 'Create Typesense collection'
  task create_collection: :environment do
    puts 'Creating Typesense collection...'

    Product.create_typesense_collection

    puts 'Collection created successfully'
  end

  desc 'Delete and recreate Typesense collection'
  task recreate: :environment do
    puts 'Deleting existing collection...'

    begin
      Product.typesense_client.collections[Product.typesense_collection_name].delete
      puts 'Collection deleted'
    rescue Typesense::Error::ObjectNotFound
      puts 'Collection does not exist'
    end

    Rake::Task['typesense:create_collection'].invoke
    Rake::Task['typesense:reindex'].invoke
  end
end

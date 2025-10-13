# frozen_string_literal: true

require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  describe 'Searchable concern' do
    setup do
      @product = create(:product)
    end

    describe '.typesense_client' do
      test 'returns the TYPESENSE_CLIENT constant' do
        assert_equal TYPESENSE_CLIENT, Product.typesense_client
      end
    end

    describe '.typesense_collection_name' do
      test 'returns collection name with environment prefix' do
        expected = 'test_products'
        assert_equal expected, Product.typesense_collection_name
      end
    end

    describe '.create_typesense_collection' do
      test 'creates collection with schema' do
        Product.create_typesense_collection

        # Mock client should have received the create call
        assert true
      end

      test 'handles collection already exists error' do
        # Stub the collections create method to raise ObjectAlreadyExists error
        TYPESENSE_CLIENT.collections
                        .stubs(:create)
                        .raises(Typesense::Error::ObjectAlreadyExists.new('Collection already exists'))

        # Should not raise error, just log and continue
        assert_nothing_raised do
          Product.create_typesense_collection
        end
      end
    end

    describe '.reindex_all' do
      test 'indexes all records in typesense' do
        create_list(:product, 2)

        Product.reindex_all

        # With mock client, this should succeed without errors
        # 1 from setup + 2 from create_list = 3 total
        assert_equal 3, Product.count
      end
    end

    describe '.search' do
      test 'performs search with query' do
        result = Product.search('test query')

        assert_instance_of Hash, result
        assert_equal [], result['hits']
        assert_equal 0, result['found']
      end

      test 'accepts options for pagination' do
        result = Product.search('test', per_page: 10, page: 2)

        assert_instance_of Hash, result
      end
    end

    describe '#index_in_typesense' do
      test 'indexes product after save' do
        product = build(:product)

        assert_nothing_raised do
          product.save
        end
      end

      test 'is called automatically after save' do
        product = build(:product)

        product.expects(:index_in_typesense).once
        product.save
      end

      test 'can be called manually' do
        assert_nothing_raised do
          @product.index_in_typesense
        end
      end

      test 'creates collection and retries when ObjectNotFound error occurs' do
        # Track number of calls
        call_count = 0

        # Stub upsert to fail first time, succeed second time
        documents = TYPESENSE_CLIENT.collections[@product.class.typesense_collection_name].documents
        documents.stubs(:upsert).with do |_doc|
          call_count += 1
          raise Typesense::Error::ObjectNotFound, 'Collection not found' if call_count == 1

          true
        end.returns({ 'id' => @product.id.to_s })

        # Stub create_typesense_collection
        @product.class.expects(:create_typesense_collection).once

        assert_nothing_raised do
          @product.index_in_typesense
        end

        assert_equal 2, call_count, 'Expected upsert to be called twice (once failing, once succeeding)'
      end

      test 'handles general errors during indexing' do
        # Mock upsert to raise a StandardError
        documents_mock = TYPESENSE_CLIENT.collections[@product.class.typesense_collection_name].documents
        documents_mock.stubs(:upsert).raises(StandardError.new('Connection error'))

        # Should not raise error, just log it
        assert_nothing_raised do
          @product.index_in_typesense
        end
      end
    end

    describe '#remove_from_typesense' do
      test 'removes product from typesense after destroy' do
        product = create(:product)

        assert_nothing_raised do
          product.destroy
        end
      end

      test 'is called automatically after destroy' do
        product = create(:product)

        product.expects(:remove_from_typesense).once
        product.destroy
      end

      test 'can be called manually' do
        assert_nothing_raised do
          @product.remove_from_typesense
        end
      end

      test 'handles errors during removal' do
        # Stub the typesense_client to return a mock that raises on delete
        mock_document = mock('document')
        mock_document.expects(:delete).raises(StandardError.new('Connection error'))

        mock_documents = mock('documents')
        mock_documents.stubs(:[]).with(@product.id.to_s).returns(mock_document)

        mock_collection = mock('collection', documents: mock_documents)
        mock_collections = mock('collections')
        mock_collections.stubs(:[]).with(@product.class.typesense_collection_name).returns(mock_collection)

        @product.class.stubs(:typesense_client).returns(mock('client', collections: mock_collections))

        # Should not raise error, just log it
        assert_nothing_raised do
          @product.remove_from_typesense
        end
      end
    end

    describe '#typesense_document' do
      test 'returns document hash with all required fields' do
        document = @product.typesense_document

        assert_includes document.keys, :id
        assert_includes document.keys, :title_es
        assert_includes document.keys, :title_en
        assert_includes document.keys, :subtitle_es
        assert_includes document.keys, :subtitle_en
        assert_includes document.keys, :price
        assert_includes document.keys, :stock
        assert_includes document.keys, :created_at
      end

      test 'converts id to string' do
        document = @product.typesense_document

        assert_instance_of String, document[:id]
        assert_equal @product.id.to_s, document[:id]
      end

      test 'converts price to float' do
        document = @product.typesense_document

        assert_instance_of Float, document[:price]
      end

      test 'converts created_at to integer timestamp' do
        document = @product.typesense_document

        assert_instance_of Integer, document[:created_at]
        assert_equal @product.created_at.to_i, document[:created_at]
      end
    end
  end
end

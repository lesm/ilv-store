# frozen_string_literal: true

require 'test_helper'

module Backoffice
  module Products
    class PublicationsControllerTest < ActionDispatch::IntegrationTest
      let(:admin) { create(:user, :admin) }
      let(:product) { create(:book).product }

      describe 'as admin' do
        before do
          authenticate_as(admin)
        end

        describe '#POST create' do
          before do
            product.unpublish!
          end

          test 'publishes the product' do
            post backoffice_product_publication_url(product, format: :turbo_stream)

            assert_predicate product.reload, :published?
          end

          test 'replaces the product card and shows a notice' do
            post backoffice_product_publication_url(product, format: :turbo_stream)

            assert_turbo_stream action: :replace, target: ActionView::RecordIdentifier.dom_id(product)
            assert_turbo_stream action: :append, target: 'flash'
            assert_match 'Producto publicado', response.body
          end
        end

        describe '#DELETE destroy' do
          test 'unpublishes the product' do
            delete backoffice_product_publication_url(product, format: :turbo_stream)

            assert_not_predicate product.reload, :published?
          end

          test 'replaces the product card and shows a notice' do
            delete backoffice_product_publication_url(product, format: :turbo_stream)

            assert_turbo_stream action: :replace, target: ActionView::RecordIdentifier.dom_id(product)
            assert_match 'Producto oculto', response.body
          end
        end
      end

      describe 'as customer' do
        before do
          authenticate_as(create(:user))
        end

        test 'does not unpublish the product' do
          delete backoffice_product_publication_url(product, format: :turbo_stream)

          assert_redirected_to root_path
          assert_predicate product.reload, :published?
        end
      end
    end
  end
end

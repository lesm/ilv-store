# frozen_string_literal: true

require 'test_helper'

module ActiveStorage
  class DirectUploadsControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user, :with_cart, role: :customer) }
    let(:admin_user) { create(:user, :with_cart, :admin) }

    let(:file) { fixture_file_upload('book.png', 'image/png') }

    let(:params) do
      {
        blob: {
          filename: 'book.png',
          byte_size: file.size,
          checksum: Digest::SHA256.file(file.path).hexdigest,
          content_type: 'image/png',
          metadata: {}
        }
      }
    end

    describe '#POST create' do
      test 'returns a 401 Unauthorized' do
        post '/rails/active_storage/direct_uploads', params: params
        assert_response :unauthorized
        assert_includes response.body, 'Authentication required'
      end

      test 'returns a 401 Unauthorized for non-admin users' do
        authenticate_as(user)

        post '/rails/active_storage/direct_uploads', params: params
        assert_response :unauthorized
        assert_includes response.body, 'Authentication required'
      end

      test 'allows admin users to create direct uploads' do
        authenticate_as(admin_user)

        post '/rails/active_storage/direct_uploads', params: params
        assert_response :success
        assert_includes response.body, 'direct_upload'
      end
    end
  end
end

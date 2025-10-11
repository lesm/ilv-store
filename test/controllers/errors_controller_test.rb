# frozen_string_literal: true

require 'test_helper'

# NOTE: ErrorsController uses ActionController::Base directly (not ApplicationController)
# and handles routes that are invoked by Rails exception handling.
# ActionController::TestCase is still appropriate for testing these error controllers.
class ErrorsControllerTest < ActionController::TestCase # rubocop:disable Rails/ActionControllerTestCase
  describe '#not_found' do
    test 'returns 404 status' do
      get :not_found

      assert_response :not_found
    end

    test 'renders error page with Spanish content' do
      get :not_found

      assert_select 'h1', text: '404'
      assert_select 'body', text: /Página no encontrada/
      assert_select 'body', text: /Algo falta aquí/
    end

    test 'includes navigation and footer' do
      get :not_found

      assert_select 'nav'
      assert_select 'footer'
    end
  end

  describe '#internal_server_error' do
    test 'returns 500 status' do
      get :internal_server_error

      assert_response :internal_server_error
    end

    test 'renders error page with Spanish content' do
      get :internal_server_error

      assert_select 'h1', text: '500'
      assert_select 'body', text: /Error del servidor/
      assert_select 'body', text: /Error interno del servidor/
    end

    test 'includes navigation and footer' do
      get :internal_server_error

      assert_select 'nav'
      assert_select 'footer'
    end
  end
end

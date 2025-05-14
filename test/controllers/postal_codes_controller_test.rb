# frozen_string_literal: true

require 'test_helper'

class PostalCodesControllerTest < ActionDispatch::IntegrationTest
  let(:postal_code) { create(:mx_postal_code, :oaxaca_centro) }
  let(:headers) { { 'Accept' => 'application/json' } }

  before do
    authenticate_as(create(:user))
  end

  describe '#GET index' do # rubocop:disable Metrics/BlockLength
    test 'returns 400 status code if postal_code param is missing' do
      get(postal_codes_url, params: {}, headers:)

      assert_response :bad_request
      assert_equal({ error: 'postal_code param is required' }.to_json, response.body)
    end

    test 'returns 404 status code if postal_code is not found' do
      get(postal_codes_url, params: { postal_code: '00000' }, headers:)

      assert_response :not_found
      assert_equal({ error: 'Postal code not found' }.to_json, response.body)
    end

    test 'returns 200 status code and postal code data if postal_code is found' do
      get(postal_codes_url, params: { postal_code: postal_code.postal_code }, headers:)

      assert_response :ok
      assert_equal({
        postal_code: '68000',
        state: {
          id: postal_code.state_id,
          name: postal_code.state_name
        },
        city: {
          id: postal_code.city_id,
          name: postal_code.city_name
        },
        neighborhoods: [postal_code.neighborhood]
      }.to_json, response.body)
    end
  end
end

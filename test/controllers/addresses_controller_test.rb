# frozen_string_literal: true

require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user, :with_cart) }
  let(:country) { create(:country) }
  let(:state) { create(:country_state, :oaxaca, country:) }
  let(:city) { create(:country_state_city, :oaxaca_de_juarez, state:) }

  let(:params) do
    {
      mexican_address: {
        full_name: 'Luis Silva',
        street_and_number: 'Calle de los libres 107',
        country_id: country.id,
        state_id: state.id,
        city_id: city.id,
        postal_code: '68000',
        neighborhood: 'Centro',
        reference: 'Portón blanco',
        phone_number: '9511121212'
      }
    }
  end

  before do
    authenticate_as(user)
    [country, state, city]
  end

  test 'returns a 200 response' do
    get addresses_url
    assert_response :success
  end

  test 'returns a 200 response' do
    get new_address_url(turbo_frame: 'drawer')
    assert_response :success
  end

  describe '#POST create' do
    describe 'with valid params' do
      test 'redirects to the addresses page' do
        post(addresses_url(format: :turbo_stream), params:)

        assert_turbo_stream action: :redirect
      end
    end

    describe 'with invalid params' do
      test 'redirects to the new address page' do
        params[:mexican_address][:postal_code] = nil
        post(addresses_url(format: :turbo_stream), params:)

        assert_turbo_stream action: :append, target: 'flash'
      end
    end
  end
end

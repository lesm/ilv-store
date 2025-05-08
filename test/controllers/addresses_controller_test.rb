# frozen_string_literal: true

require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  let(:user) { create(:user, :with_cart) }
  let(:country) { create(:country) }
  let(:state) { create(:country_state, :oaxaca, country:) }
  let(:city) { create(:country_state_city, :oaxaca_de_juarez, state:) }

  before do
    authenticate_as(user)
  end

  test 'should get index' do
    get addresses_url
    assert_response :success
  end

  test 'should get new' do
    [country, state, city]

    get new_address_url(turbo_frame: 'drawer')
    assert_response :success
  end

  test 'should post create' do
    params = {
      address: {
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

    post(addresses_url, params:)

    assert_redirected_to addresses_url
  end
end

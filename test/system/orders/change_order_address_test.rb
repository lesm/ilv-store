# frozen_string_literal: true

require 'application_system_test_case'

class ChangeOrderAddressTest < ApplicationSystemTestCase
  let(:password) { SecureRandom.hex }
  let(:user) { create(:user, :with_cart, email: 'mail@mail.com', password:, password_confirmation: password) }
  let(:address1) { create(:address, :oxxo_bustamante, addressable: user, default: true) }
  let(:address2) { create(:address, :oxxo_llano, addressable: user) }
  let(:address3) { create(:address, :oxxo_santo_domingo, addressable: user) }

  before do
    [address1, address2, address3]

    sign_in(user, password)
  end

  test 'change order address' do
    find('nav').find('a[data-turbo-frame="drawer"]').click
    click_on 'Proceder al pago'

    click_on 'Cambiar'
    click_on 'Santiago Pérez'

    assert_text 'Enviar a Santiago Pérez'

    click_on 'Cambiar'
    click_on 'Mateo Pérez'

    assert_text 'Enviar a Mateo Pérez'
  end
end

# frozen_string_literal: true

require 'application_system_test_case'

class SignInTest < ApplicationSystemTestCase
  before do
    create(:user, email_address: 'mail@mail.com', password: 'password')
  end

  test 'signs in successfully' do
    visit root_path

    click_on 'Iniciar sesión'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    fill_in 'Contraseña', with: 'password'

    click_on 'Iniciar sesión'

    assert_text 'Bienvenido de nuevo'
  end

  test 'signs in unsuccessfully' do
    visit root_path

    click_on 'Iniciar sesión'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    fill_in 'Contraseña', with: 'invalid password'

    click_on 'Iniciar sesión'

    assert_text 'No se pudo iniciar sesión. Por favor, verifica tus credenciales.'
  end
end

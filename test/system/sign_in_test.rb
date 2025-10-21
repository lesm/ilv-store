# frozen_string_literal: true

require 'application_system_test_case'

class SignInTest < ApplicationSystemTestCase
  let(:password) { SecureRandom.hex }

  before do
    create(:user, email: 'mail@mail.com', password:, password_confirmation: password)
  end

  test 'signs in successfully' do
    visit root_path

    click_on 'Entrar'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    fill_in 'Contraseña', with: password

    click_on 'Iniciar sesión'

    assert_text 'Bienvenido de nuevo'
  end

  test 'signs in unsuccessfully' do
    visit root_path

    click_on 'Entrar'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    fill_in 'Contraseña', with: 'invalid password'

    click_on 'Iniciar sesión'

    assert_text 'No se pudo iniciar sesión. Por favor, verifica tus credenciales.'
  end
end

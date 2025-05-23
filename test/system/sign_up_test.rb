# frozen_string_literal: true

require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  test 'signs up successfully' do
    visit root_path

    click_on 'Registrarse'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    password = SecureRandom.hex
    fill_in 'Contraseña', with: password
    fill_in 'Confirmar contraseña', with: password

    click_on 'Crear cuenta'

    assert_text 'Cuenta creada, por favor revisa tu correo electrónico para verificar tu cuenta.'
  end

  test 'signs up unsuccessfully' do
    visit root_path

    click_on 'Registrarse'

    fill_in 'Correo electrónico', with: 'mail@mail.com'
    fill_in 'Contraseña', with: 'one password'
    fill_in 'Confirmar contraseña', with: 'another password'

    click_on 'Crear cuenta'

    assert_text 'Confirmar contraseña no coincide'
  end
end

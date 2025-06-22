# frozen_string_literal: true

module System
  module SessionHelper
    def sign_in(user, password)
      visit root_path
      click_on 'Iniciar sesión'
      fill_in 'Correo electrónico', with: user.email
      fill_in 'Contraseña', with: password
      click_on 'Iniciar sesión'
    end
  end
end

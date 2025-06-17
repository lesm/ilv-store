# frozen_string_literal: true

resource :session, only: %i[new create destroy]
resource :registration, only: %i[new create]
resources :passwords, only: %i[new create edit update], param: :token

resources :products
resources :addresses

resource :cart, only: %i[show] do
  resources :items, only: %i[create update destroy], controller: 'carts/items'
end

resources :orders, only: %i[index new create]

scope module: :orders, path: :order, as: :order do
  resources :addresses, only: %i[index update]
end

resource :user, only: %i[] do
  resource :theme_preference, only: %i[update], controller: 'users/theme_preference'
  resource :email_verification, only: %i[show], controller: 'users/email_verifications'
end

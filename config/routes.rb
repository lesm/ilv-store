# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  resources :passwords, only: %i[new create edit update], param: :token

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :products

  resource :cart, only: %i[show] do
    resources :items, only: %i[create destroy], controller: 'carts/items'
  end

  root 'products#index'
end

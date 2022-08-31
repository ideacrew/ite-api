# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reset_passwords, controller: 'rails_jwt_auth/reset_passwords', only: %i[show create update]

  resource :user, controller: 'rails_jwt_auth/profiles', only: %i[show update] do
    collection do
      put :email
      put :password
    end
  end

  resource :registration, controller: 'rails_jwt_auth/registrations', only: [:create]
  resource :session, controller: 'rails_jwt_auth/sessions', only: %i[create destroy]

  namespace :api do
    namespace :v1 do
      resources :extracts, only: %i[index show] do
        collection do
          post 'ingest'
        end
      end

      resources :providers, only: %i[index create update show]
    end
  end
end

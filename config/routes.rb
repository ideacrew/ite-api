# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reset_passwords, controller: 'rails_jwt_auth/reset_passwords', only: %i[show create update]

  resource :user, controller: 'rails_jwt_auth/profiles', only: %i[show update] do
    collection do
      put :email
      put :password
    end
  end

  resource :session, controller: 'rails_jwt_auth/sessions', only: %i[create destroy]

  namespace :api do
    namespace :v1 do
      resources :extracts, only: %i[index show] do
        collection do
          post 'ingest'
          get 'failing_records'
        end
      end

      resources :providers, only: %i[index create update show] do
        collection do
          get 'submission_summary'
        end
      end
    end
  end
end

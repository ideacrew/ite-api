# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
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

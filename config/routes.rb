Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :v1 do
  	resource :requests, only: [] do
      collection do
        post 'create'
      end
    end
  end
end
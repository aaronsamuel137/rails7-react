Rails.application.routes.draw do
  root 'homepage#index'

  namespace :api do
    namespace :v1 do
      resources :questions, only: :show do
        post :ask, on: :collection
      end
    end
  end
end

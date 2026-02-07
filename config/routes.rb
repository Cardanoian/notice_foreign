Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resource :settings, only: [ :show, :update ]
  resources :passwords, param: :token
  root "home#index"

  resources :schools, only: [ :index, :show ] do
    resources :docs, only: [ :index, :show ]
  end

  namespace :api do
    resources :schools, only: [ :index ] do
      collection do
        get :locations
      end
    end
    resources :docs, only: [ :show ] do
      member do
        post :chat
      end
    end
  end

  namespace :admin do
    resources :original_docs, only: [ :index, :show, :new, :create, :destroy ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

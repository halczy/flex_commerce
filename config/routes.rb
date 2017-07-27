Rails.application.routes.draw do
  root 'home#index'

  get 'index',  to: 'home#index'
  get 'signup', to: 'customers#new'
  get 'signin', to: 'sessions#new'

  resources :customers, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]
  resources :images, only: [:show]

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :categories do
      member do
        patch 'move'
      end
    end
    resources :products
    resources :images, only: [:index, :create, :show, :destroy]
  end
end

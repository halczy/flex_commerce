Rails.application.routes.draw do
  root 'home#index'

  get 'index',  to: 'home#index'
  get 'signup', to: 'customers#new'
  get 'signin', to: 'sessions#new'

  resources :customers,  only: [:new, :create, :show]
  resources :sessions,   only: [:new, :create, :destroy]
  resources :images,     only: [:show]
  resources :categories, only: [:show] do
    collection do
      get :search
    end
  end
  resources :products,   only: [:show]

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :categories do
      member do
        patch 'move'
      end
    end
    resources :products do
      collection do
        get 'search'
      end
    end
    resources :images, only: [:index, :create, :show, :destroy]
  end
end

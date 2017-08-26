Rails.application.routes.draw do
  root 'home#index'

  get  'index',     to: 'home#index'
  get  'signup',    to: 'customers#new'
  get  'signin',    to: 'sessions#new'
  get  'cart',      to: 'carts#show'
  post 'cart/add',  to: 'carts#add',     as: :add_to_cart

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
    resources :dashboard, only: [:index]                          # Dashboard
    resources :categories do                                      # Categories
      member do
        patch 'move'
      end
    end
    resources :products do                                        # Products
      collection do
        get 'search'
      end
      member do
        get    'inventories'
        post   'add_inventories'
        patch  'remove_inventories'
        patch  'force_remove_inventories'
      end
    end
    resources :images, only: [:index, :create, :show, :destroy]   # Images
    resources :inventories, only: [:index, :show, :destroy]       # Inventories
  end
end

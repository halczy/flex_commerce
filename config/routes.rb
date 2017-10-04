Rails.application.routes.draw do
  root 'home#index'

  get    'index',         to: 'home#index'
  get    'signup',        to: 'customers#new'
  get    'signin',        to: 'sessions#new'
  get    'cart',          to: 'carts#show'
  patch  'cart',          to: 'carts#update'
  post   'cart/add',      to: 'carts#add',    as: :add_to_cart
  delete 'cart/remove',   to: 'carts#remove', as: :remove_from_cart

  resources :dashboards, only: [:show]
  resources :customers,  only: [:new, :create, :show]
  resources :sessions,   only: [:new, :create, :destroy]
  resources :images,     only: [:show]
  resources :categories, only: [:show] do
    collection do
      get :search
    end
  end
  resources :products,   only: [:show]
  resources :addresses do
    collection do
        get :update_selector
    end
  end
  resources :orders, only: [:index, :create, :show, :destroy] do
    member do
      get   :shipping
      patch :set_shipping
      get   :address
      post  :create_address
      patch :set_address
      get   :review
      patch :confirm
      get   :payment
      post  :create_wallet_payment
      post  :create_alipay_payment
      get   :success
      get   :resume
    end
    collection do
      get   :update_selector
    end
  end
  resources :payments, only: [] do
    member do
      get  :alipay_return
      post :alipay_notify
    end
  end

  namespace :admin do
    resources :dashboard, only: [:index]                          # Dashboard
    resources :customers do                                       # Customers
      collection do
        get :search
      end
    end
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
    resources :inventories, only: [:index, :show, :destroy]       # Inventories
    resources :orders, only: [:index, :show, :destroy] do         # Orders
      collection do
        get   :search
      end
      member do
        patch :confirm
        patch :set_pickup_ready
        post  :add_tracking
        patch :complete_pickup
        patch :complete_shipping
      end
    end
    resources :images, only: [:index, :create, :show, :destroy]   # Images
    resources :geos, only: [:index] do                            # Geos
      collection do
        get 'search'
      end
    end
    resources :shipping_methods                                   # Shipping Methods
  end
end

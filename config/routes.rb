Rails.application.routes.draw do
  root 'home#index'

  get 'index',  to: 'home#index'
  get 'signup', to: 'users#new'
  get 'signin', to: 'sessions#new'

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :categories
end

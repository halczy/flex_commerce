Rails.application.routes.draw do
  root 'home#index'

  get 'index',  to: 'home#index'
  get 'signup', to: 'customers#new'
  get 'signin', to: 'sessions#new'

  resources :customers, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]
  resources :categories

  namespace :admin do
    resources :dashboard, only: [:index]
  end
end

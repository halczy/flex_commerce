Rails.application.routes.draw do

  root 'home#index'

  get 'index',  to: 'home#index'
  get 'signup', to: 'users#new'

  resources :users

end

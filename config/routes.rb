Rails.application.routes.draw do

  root 'home#homepage'

  get 'homepage', to: 'home#homepage'
  resources :users

end

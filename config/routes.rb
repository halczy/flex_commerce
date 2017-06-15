Rails.application.routes.draw do

  root 'home#homepage'

  get 'homepage', to: 'home#homepage'

end

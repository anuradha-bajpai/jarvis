Rails.application.routes.draw do
  resources :predictions

  namespace :admin do
    resources :predictions
  end

  root 'predictions#new'

end

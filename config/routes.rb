Rails.application.routes.draw do
  devise_for :accounts
  root to: 'static_content#main'

  resources :projects, param: :slug


end

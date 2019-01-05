Rails.application.routes.draw do

  devise_for :accounts, controllers: {
    registrations: 'accounts/registrations',
    passwords: 'accounts/passwords'
  }

  root to: 'static_content#main'

  resources :projects, param: :slug do
    get 'settings', to: "project_settings#edit"
    patch 'settings', to: "project_settings#update"
    post 'toggle_pause', to: "project_settings#toggle_pause"
  end

  get 'directory', to: "directory#index"
  match 'directory/:slug', to: "directory#show", via: :get, as: :directory_project

end

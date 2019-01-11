# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    registrations: 'accounts/registrations',
    passwords: 'accounts/passwords'
  }

  root to: 'static_content#main'

  resources :accounts

  get 'watermark.svg', to: 'watermarks#show', format: :xml

  resources :issues

  resources :projects, param: :slug do
    resources :issues do
      resources :issue_comments, only: %i[create new]
      post 'acknowledge', to: 'issues#acknowledge'
      post 'dismiss', to: 'issues#dismiss'
      post 'resolve', to: 'issues#resolve'
      post 'reopen', to: 'issues#reopen'
    end
    get 'settings', to: 'project_settings#edit'
    patch 'settings', to: 'project_settings#update'
    post 'toggle_pause', to: 'project_settings#toggle_pause'
  end

  get 'directory', to: 'directory#index'
  match 'directory/:slug', to: 'directory#show', via: :get, as: :directory_project
end

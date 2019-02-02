Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    registrations: "accounts/registrations",
    passwords: "accounts/passwords"
  }

  root to: "static_content#main"

  resources :accounts

  get "watermark.svg", to: "watermarks#show", format: :xml

  resources :abuse_reports, only: [:new, :create]
  resources :issues
  resources :projects, param: :slug do
    resources :account_project_blocks
    resources :issues do
      resources :uploads
      resources :issue_comments, only: [:create, :new]
      resources :issue_invitations, only: [:create, :new]
      post "acknowledge", to: "issues#acknowledge"
      post "dismiss", to: "issues#dismiss"
      patch "resolve", to: "issues#resolve"
      post "reopen", to: "issues#reopen"
    end
    resources :issue_severity_levels
    resources :reporters, only: [:show]
    resources :respondent_templates, only: [:new, :create, :edit, :update, :show]
    resources :respondents, only: [:show]
    get "settings", to: "project_settings#edit"
    get "ownership", to: "projects#ownership"
    patch "clone_ladder", to: "projects#clone_ladder"
    patch "clone_respondent_template", to: "respondent_templates#clone"
    patch "confirm", to: "projects#confirm_ownership"
    patch "settings", to: "project_settings#update"
    post "toggle_pause", to: "project_settings#toggle_pause"
  end

  namespace :admin do
    resources :abuse_reports do
      post "dismiss", to: "abuse_reports#dismiss"
      post "resolve", to: "abuse_reports#resolve"
    end
    resources :projects, param: :slug do
      patch "flag", to: "projects#flag"
      post "unflag", to: "projects#unflag"
    end
  end

  get "directory", to: "directory#index"
  match "directory/:slug", to: "directory#show", via: :get, as: :directory_project
end

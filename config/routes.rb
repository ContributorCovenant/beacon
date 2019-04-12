require 'resque/server'

Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    registrations: "accounts/registrations",
    passwords: "accounts/passwords",
    omniauth_callbacks: 'accounts/omniauth_callbacks',
    verify_authy: "/verify-token",
    enable_authy: "/enable-two-factor",
    verify_authy_installation: "/verify-installation",
    authy_onetouch_status: "/onetouch-status"
  }

  # Resque background jobs
  authenticate :account, ->(u) { u.is_admin? } do
    mount Resque::Server.new, at: "/resque"
  end

  root to: "static_content#main"
  get "about", to: "static_content#about"
  get "user_guides", to: "static_content#guide"

  resources :abuse_reports, only: [:new, :create]
  resources :accounts
  resources :contact_messages, only: [:new, :create]

  resources :invitations, only: [:create, :index] do
    post "accept", to: "invitations#accept"
    post "reject", to: "invitations#reject"
  end

  resources :issues

  resources :organizations, param: :slug do
    resources :invitations, only: [:create]
    resource :autoresponder
    resource :respondent_template
    resource :consequence_guide do
      resources :consequences
      patch "clone", to: "consequence_guides#clone"
    end
    get "moderators", to: "organizations#moderators"
    get "import_projects_from_github", to: "organizations#import_projects_from_github"
    get "gitlab_auth_token", to: "organizations#gitlab_auth_token"
    post "import_projects_from_gitlab", to: "organizations#import_projects_from_gitlab"
    get "github_auth_token", to: "organizations#github_auth_token"
    post "import_projects_from_github", to: "organizations#import_projects_from_github"
    post "remove_moderator", to: "organizations#remove_moderator"
    post "clone_autoresponder", to: "autoresponders#clone"
    patch "clone_autoresponder", to: "autoresponders#clone"
    post "clone_respondent_template", to: "respondent_templates#clone"
    patch "clone_respondent_template", to: "respondent_templates#clone"
  end

  resources :projects, param: :slug do
    resources :account_project_blocks
    resource :autoresponder
    resource :consequence_guide do
      resources :consequences
      patch "clone", to: "consequence_guides#clone"
    end
    resources :invitations, only: [:new, :create]
    resources :issues do
      resources :issue_comments, only: [:create, :new]
      resources :issue_invitations, only: [:create, :new]
      resources :surveys, only: [:create, :new, :show]
      resources :uploads
      post "acknowledge", to: "issues#acknowledge"
      post "dismiss", to: "issues#dismiss"
      patch "resolve", to: "issues#resolve"
      post "reopen", to: "issues#reopen"
    end
    resources :reporters, only: [:show]
    resource :respondent_template
    resources :respondents, only: [:show]

    get "settings", to: "project_settings#edit"
    get "moderators", to: "projects#moderators"
    get "ownership", to: "projects#ownership"
    get "token", to: "projects#token"
    post "clone_autoresponder", to: "autoresponders#clone"
    patch "clone_autoresponder", to: "autoresponders#clone"
    post "clone_respondent_template", to: "respondent_templates#clone"
    post "remove_moderator", to: "projects#remove_moderator"
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
    resources :accounts do
      patch "flag", to: "accounts#flag"
      post "unflag", to: "accounts#unflag"
    end
    resources :projects, param: :slug do
      patch "flag", to: "projects#flag"
      post "unflag", to: "projects#unflag"
    end
    resources :organizations do
      patch "flag", to: "organizations#flag"
      post "unflag", to: "organizations#unflag"
    end
  end

  get "directory", to: "directory#index"
  post "directory", to: "directory#search", as: :directory_search
  match "directory/:slug", to: "directory#show", via: :get, as: :directory_project

end

Gregory::Application.routes.draw do
  resque_server = Rack::Auth::Basic.new(Resque::Server) do |_,password|
    password == ENV['RESQUE_HTTP_AUTH_PASSWORD']
  end
  mount resque_server, at: 'resque'
  mount StitchFix::ProofOfLife::Engine, at: "/proof_of_life"

  namespace :api do
    scope module: :v1, constraints: Stitches::ApiVersionConstraint.new(1) do
      resource 'ping', only: [ :create ]
      resources :responsys_events, only: :show
      resources :subscriptions, only: [:show, :update]
      resources :email_batches, only: [:create]
      resources :emails, only: [:create]
      get 'ced_files/:date', to: 'ced_files#show'
    end
    scope module: :v2, constraints: Stitches::ApiVersionConstraint.new(2) do
      resource 'ping', only: [ :create ]
      resources :subscriptions, only: [:show, :update], id: /(\d+|.*@*)/
    end
  end
end

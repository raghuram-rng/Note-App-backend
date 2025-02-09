Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/notes/search", to: "notes#search"
  resources :notes
  resources :sessions, except: [:index]
  resources :registrations, only: [:new, :create, :edit, :update]
  post 'login', to: 'sessions#create'
  post 'signup', to: 'registrations#create'

  delete :logout, to: "sessions#logout"
  get :logged_in, to: "sessions#logged_in"
  # # Defines the root path route ("/")
  # root "static#home"
  mount Test::Base => '/'
  # Defines the root path route ("/")
  root "sessions#new"
end

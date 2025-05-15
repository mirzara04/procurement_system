Rails.application.routes.draw do
  # Root route
  root 'dashboard#index'

  # Devise routes for authentication
  devise_for :users

  # Dashboard routes
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/analytics', to: 'dashboard#analytics'

  # Main resources
  resources :vendors do
    resources :vendor_documents, shallow: true
    resources :vendor_ratings, shallow: true
    member do
      patch :approve
      patch :blacklist
      get :performance
    end
  end

  resources :purchase_orders do
    resources :purchase_order_items, shallow: true
    member do
      patch :submit_for_approval
      patch :approve
      patch :reject
      patch :mark_as_received
      get :print
    end
    collection do
      get :pending_approval
      get :approved
    end
  end

  resources :products do
    collection do
      get :low_stock
      get :discontinued
    end
  end

  # Reports
  namespace :reports do
    get 'vendor_performance'
    get 'procurement_analytics'
    get 'spending_analysis'
    get 'delivery_performance'
  end

  # API endpoints for dynamic updates
  namespace :api do
    resources :vendors, only: [:index] do
      get :search, on: :collection
    end
    resources :products, only: [:index] do
      get :search, on: :collection
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

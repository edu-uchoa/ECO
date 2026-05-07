Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :users, only: [:new, :create, :show]
  resource :profile, only: [:show, :edit, :update, :destroy]
  resources :posts do
    member do
      post :claim
    end
    resource :review, only: [:create, :destroy]
  end
  resources :private_conversations, only: [:index, :create, :show] do
    resources :messages, only: [:create] do
      member do
        post :accept_claim
        post :reject_claim
      end
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
    root "pages#home"
    get "dashboard", to: "pages#dashboard"
    get "mapa", to: "pages#map", as: :map
    post "chatbot/ask", to: "chatbot#ask", as: :chatbot_ask

  resources :collection_points, only: [:index, :create]

  get "moderation", to: "moderation/collection_points#index", as: :moderation_dashboard

  namespace :moderation do
    resources :collection_points, only: [:index] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
end

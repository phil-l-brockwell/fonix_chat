Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resources :confirmations, param: :token, only: %i[ new create show ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "chat#show"
end

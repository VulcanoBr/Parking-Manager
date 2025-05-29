Rails.application.routes.draw do
  # Define a rota principal para o dashboard
  root 'dashboard#index'

  # Rotas de autenticação
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # Dashboard
  get 'dashboard', to: 'dashboard#index'

  # Recursos aninhados
  resources :parking_lots do
    resources :parking_spots, only: [:index, :edit, :update]

    resources :parking_records do
      member do
        get 'checkout'
        get 'payment'
        post 'mark_as_paid'
      end
      collection do
        get :next_available_spot
      end
    end

    # Rotas para relatórios
    resources :reports, only: [:index] do
      collection do
        get 'occupancy'
        get 'revenue'
        get 'average_time'
      end
    end
  end
end

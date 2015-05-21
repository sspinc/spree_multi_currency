Spree::Core::Engine.add_routes do
  post '/currency/set', to: 'currency#set', defaults: { format: :json }, as: :set_currency

  namespace :admin do
    resources :products do
      resources :prices, only: [:index, :create]
    end

    resource :general_settings do
      collection do
        post :calculate_prices
      end
    end
  end
end

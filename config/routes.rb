Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :specimen
      resources :roles
      resources :departments
      resources :drugs
      resources :organisms
      resources :test_panels
      resources :statuses
      resources :status_reasons
      resources :test_types
      resources :users do
        get '/current/'  => 'users#current_user'
      end
      post '/login/' => 'users#login'
      get '/test_indicator_types/' => 'test_types#test_indicator_types'
      get '/refresh_token/' => 'users#refresh_token'
    end
  end
end
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :specimen
      resources :roles
      resources :departments
      resources :drugs
      resources :users do
        get '/current/'  => 'users#current_user'
      end
      post '/login/' => 'users#login'
      get '/refresh_token/' => 'users#refresh_token'
    end
  end
end
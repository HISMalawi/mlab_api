Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :specimen
      resources :roles do
        collection do
         put '/update_permissions/' => 'roles#update_permissions'
        end
      end
      resources :departments
      resources :privileges
      resources :drugs
      resources :organisms
      resources :test_panels
      resources :statuses
      resources :status_reasons
      resources :test_types do
        collection do
          get '/test_indicator_types/' => 'test_types#test_indicator_types'
        end
      end
      resources :users do
        collection do
          put '/activate/:id' => 'users#activate'
          put 'change_password/:id' => 'users#update_password'
          put 'change_username/:id' => 'users#change_username'
        end
      end
      post '/auth/login' => 'auth#login'
      post '/auth/application_login' => 'auth#application_login'
      get '/auth/refresh_token/' => 'auth#refresh_token'
      resources :clients do
        collection do
          get '/identifier_types/' => 'clients#identifier_types'
        end
      end

      resources :diseases
      resources :surveillances
    end
  end
end
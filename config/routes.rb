Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :interfacer, only: %i[create] do
        collection do
          get '/fetch_results/' => 'interfacer#fetch_results'
          get '/result_available/' => 'interfacer#result_available'
        end
      end
      resources :specimen do 
        collection do
          get '/test_types/' => 'specimen#specimen_test_type'
        end
      end
      resources :roles do
        collection do
          put '/update_permissions/' => 'roles#update_permissions'
        end
      end
      resources :encounter_types
      resources :encounter_type_facility_section_mappings do
        collection do
          get '/facility_sections/' => 'encounter_type_facility_section_mappings#encounter_type_facility_sections'
        end
      end
      resources :specimen_test_type_mappings
      resources :instruments
      resources :departments
      resources :privileges
      resources :drugs
      resources :organisms do
        collection do
          get '/get_organisms_based_test_type' => 'organisms#get_organisms_based_test_type'
        end
      end
      resources :test_panels
      resources :test_results
      resources :facilities
      resources :facility_sections
      resources :statuses
      resources :status_reasons
      resources :tests do 
        collection do
          get '/:client_id/report' => 'tests#report'
        end
      end
      get '/printout/accession_number' => 'printout#print_accession_number' 
      get '/printout/tracking_number' => 'printout#print_tracking_number'
      get '/printout/patient_zebra_report'   => 'printout#print_zebra_report'
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
          get '/search_dde' => 'clients#dde_search_client'
        end
      end
      resources :orders  do 
        collection do
          get '/search_by_accession_or_tracking_number' => 'orders#search_by_accession_or_tracking_number'
          post '/add_test_to_order' => 'orders#add_test_to_order'
          post '/merge_order_from_nlims' => 'orders#merge_order_from_nlims'
          get '/search_order_from_nlims_by_tracking_number' => 'orders#search_order_from_nlims_by_tracking_number'
        end
      end

      resources :diseases
      resources :test_statuses, only: %i[index] do
        collection do
          get '/all' => 'test_statuses#get_test_statuses'
          put "/:test_id/not_received" => "test_statuses#not_received"
          put "/:test_id/started" => "test_statuses#started"
          put "/:test_id/completed" => "test_statuses#completed"
          put "/:test_id/verified" => "test_statuses#verified"
          put "/:test_id/voided" => "test_statuses#voided"
          put "/:test_id/not_done" => "test_statuses#not_done"
          put "/:test_id/rejected" => "test_statuses#rejected"
        end
      end
      resources :global
      resources :priorities
      resources :surveillances
      resources :order_statuses, only: %i[index] do 
        collection do 
          put "/rejected" => "order_statuses#specimen_rejected"
          put "/accepted" => "order_statuses#specimen_accepted"
          put "/not-collected" => "order_statuses#specimen_not_collected"
        end
      end
      resources :culture_observations do 
        collection do
          post '/drug_susceptibility_test_results' => "culture_observations#drug_susceptibility_test_results"
          put '/drug_susceptibility_test_results/delete' => "culture_observations#delete_drug_susceptibility_test_results"
          get '/get_drug_susceptibility_test_results' => "culture_observations#get_drug_susceptibility_test_results"
        end
      end
    end
  end
end
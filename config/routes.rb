# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/'
  mount Sidekiq::Web => '/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :html } do
    namespace :v1 do
      resources :print_patient_reports
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :interfacer, only: %i[index] do
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
      resources :lab_locations
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

      get '/analytics/home' => 'analytics#home_dashboard'

      get '/printout/accession_number' => 'printout#print_accession_number'
      get '/printout/tracking_number' => 'printout#print_tracking_number'
      post '/printout/patient_zebra_report' => 'printout#print_zebra_report'
      post '/printout/patient_report' => 'printout#print_patient_report'
      post '/printout/general_report' => 'printout#print_general_report'
      resources :test_types do
        collection do
          get '/test_indicator_types/' => 'test_types#test_indicator_types'
          get '/by_department' => 'test_types#department_test_types'
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
      get '/auth/logout' => 'auth#logout'
      resources :clients do
        collection do
          get '/identifier_types/' => 'clients#identifier_types'
          get '/search_dde' => 'clients#dde_search_client'
          get '/search_by_name' => 'clients#search_by_name'
        end
      end
      resources :orders do
        collection do
          get '/search_by_accession_or_tracking_number' => 'orders#search_by_accession_or_tracking_number'
          post '/add_test_to_order' => 'orders#add_test_to_order'
          post '/merge_order_from_nlims' => 'orders#merge_order_from_nlims'
          get '/search_order_from_nlims_by_tracking_number' => 'orders#search_order_from_nlims_by_tracking_number'
          get '/search_by_requesting_clinician' => 'orders#search_by_requesting_clinician'
        end
      end

      resources :diseases
      resources :test_statuses, only: %i[index] do
        collection do
          get '/all' => 'test_statuses#get_test_statuses'
          put '/:test_id/not_received' => 'test_statuses#not_received'
          put '/:test_id/started' => 'test_statuses#started'
          put '/:test_id/completed' => 'test_statuses#completed'
          put '/:test_id/verified' => 'test_statuses#verified'
          put '/:test_id/voided' => 'test_statuses#voided'
          put '/:test_id/not_done' => 'test_statuses#not_done'
          put '/:test_id/rejected' => 'test_statuses#rejected'
        end
      end
      resources :global do
        collection do
          get 'current_api_tag' => 'global#current_git_tag'
          get 'nlims_status' => 'global#nlims_status'
        end
      end
      resources :priorities
      resources :surveillances
      resources :order_statuses, only: %i[index] do
        collection do
          put '/rejected' => 'order_statuses#specimen_rejected'
          put '/accepted' => 'order_statuses#specimen_accepted'
          put '/not-collected' => 'order_statuses#specimen_not_collected'
        end
      end
      resources :culture_observations do
        collection do
          post '/drug_susceptibility_test_results' => 'culture_observations#drug_susceptibility_test_results'
          put '/drug_susceptibility_test_results/delete' => 'culture_observations#delete_drug_susceptibility_test_results'
          get '/get_drug_susceptibility_test_results' => 'culture_observations#get_drug_susceptibility_test_results'
        end
      end
      resources :printers
      resources :moh_reports do
        collection do
          get '/report_indicators' => 'moh_reports#report_indicators'
          get '/haematology' => 'moh_reports#haematology'
          get '/blood_bank' => 'moh_reports#blood_bank'
          get '/biochemistry' => 'moh_reports#biochemistry'
          get '/parasitology' => 'moh_reports#parasitology'
          get '/microbiology' => 'moh_reports#microbiology'
          get '/serology' => 'moh_reports#serology'
        end
      end
      resources :reports do
        collection do
          get '/daily_reports/daily_log' => 'daily_reports#daily_log'
        end
      end
      resources :reports do
        collection do
          get '/aggregate/lab_statistics' => 'aggregate_report#lab_statistics'
          get '/aggregate/drilldown' => 'aggregate_report#drilldown'
          get '/aggregate/malaria_report' => 'aggregate_report#malaria_report'
          get '/aggregate/user_statistics' => 'aggregate_report#user_statistics'
          get '/aggregate/infection' => 'aggregate_report#infection'
          get '/aggregate/turn_around_time' => 'aggregate_report#turn_around_time'
          get '/aggregate/rejected' => 'aggregate_report#rejected'
          get '/aggregate/culture/general_counts' => 'aggregate_report#general_count'
          get '/aggregate/culture/wards_based_counts' => 'aggregate_report#wards_based_count'
          get '/aggregate/culture/organisms_based_counts' => 'aggregate_report#organisms_based_count'
          get '/aggregate/culture/organisms_wards_counts' => 'aggregate_report#organisms_in_wards_count'
          get '/aggregate/culture/ast' => 'aggregate_report#ast'
          get '/aggregate/department' => 'aggregate_report#department_report'
          get '/aggregate/tb_tests' => 'aggregate_report#tb_tests'
        end
      end
      resources :stock_units
      resources :stock_categories
      resources :stock_suppliers
      resources :stock_locations
      resources :stock_items
      resources :stocks
      resources :stock_transaction_types
      resources :stock_orders do
        collection do
          get '/check_voucher_number' => 'stock_orders#check_voucher_number_if_already_used'
          get '/stock_statuses' => 'stock_orders#stock_statuses'
        end
      end
      resources :stock_order_statuses do
        collection do
          put '/approve_order_request' => 'stock_order_statuses#approve_stock_order_request'
          put '/reject_order' => 'stock_order_statuses#reject_stock_order'
          put '/approve_stock_requisition_request' => 'stock_order_statuses#approve_stock_requisition_request'
          put '/reject_requisition' => 'stock_order_statuses#reject_stock_requisition'
          post '/receive_requisition' => 'stock_order_statuses#receive_stock_requisition'
          put '/receive_stock_order' => 'stock_order_statuses#receive_stock_order'
          put '/stock_requisition_not_collected' => 'stock_order_statuses#stock_requisition_not_collected'
          put '/approve_stock_order_receipt' => 'stock_order_statuses#approve_stock_order_receipt'
          put '/approve_stock_requisition' => 'stock_order_statuses#approve_stock_requisition'
        end
      end
      resources :stock_pharmacy_approver_and_issuers
      resources :stock_movements do
        collection do
          get '/deduction_allowed' => 'stock_movement#stock_deduction_allowed'
          post '/issue_stock_out' => 'stock_movement#issue_stock_out'
          put '/approve_issue_out' => 'stock_movement#approve_stock_movement'
          get '/stock_items_with_respective_transaction' => 'stock_movement#stock_items_with_respective_transaction'
          get '/transactions' => 'stock_movement#stock_transaction_list'
          get '/stock_movement_with_respective_transaction' => 'stock_movement#stock_movement_with_respective_transaction'
          put '/reject_issue_out' => 'stock_movement#reject_stock_movement'
          put '/adjust_stock' => 'stock_movement#stock_adjustment'
          put '/reverse_stock_adjustment' => 'stock_movement#reverse_stock_adjustment'
          post '/receive_external_stock' => 'stock_movement#receive_stock_from_supplier_or_facility'
        end
      end
      resources :stock_adjustment_reasons
      resources :stock_reports do
        collection do
          get '/stock_movement' => 'stock_reports#stock_movement_report'
        end
      end
    end
  end
end

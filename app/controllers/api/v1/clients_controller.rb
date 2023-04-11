module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_client, only: [:show, :update, :destroy]
      before_action :validate_params, only: [:update, :create]
    
      def index
        @clients = Client.all.page(params[:page]).per(params[:per_page])
        render json: {
          clients: ClientManagement::ClientService.serialize_clients(@clients), 
          meta: PaginationService.pagination_metadata(@clients)
        }
      end

      def identifier_types
        @identifier_types = ClientIdentifierType.all.pluck('id, name')
        render json: @identifier_types
      end
      
      def show
        render json: ClientManagement::ClientService.get_client(@client.id)
      end
    
      def create
        @client = ClientManagement::ClientService.create_client(client_params)
        render json: ClientManagement::ClientService.get_client(@client.id), status: :created
      end
    
      def update
        ClientManagement::ClientService.update_client(@client, client_params)
        render json: ClientManagement::ClientService.get_client(@client.id)
      end
    
      def destroy
        ClientManagement::ClientService.void_client(@client, params.require(:reason))
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_client
        @client = Client.find(params[:id])
      end
    
      def client_params
        params.permit(client: %i[uuid], 
          person: %i[first_name middle_name last_name sex date_of_birth birth_date_estimated], 
          client_identifiers: [:type, :value])
      end
      
      def validate_params
        unless params.has_key?('client_identifiers') && params[:client_identifiers].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for client_identifiers"
        end
      end
    end
    
  end
end
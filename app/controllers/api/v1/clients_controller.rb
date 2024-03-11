module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_client, only: [:show, :update, :destroy]
      before_action :validate_params, only: [:update, :create]
      before_action :dde, only: [:create, :dde_search_client]

      def index
        if params[:search].blank? && params[:from].blank? && params[:to].blank?
          last_client_date = Client.last&.created_date
          prev_date = prev_days_date(last_client_date, 30)
          @clients = Client.where("created_date > '#{prev_date}'").order(id: :desc).page(params[:page]).per(params[:per_page])
        elsif params[:from].present? && params[:to].present?
          @clients = Client.where("DATE(created_date) BETWEEN '#{params[:from].to_date}' AND '#{params[:to].to_date}'").order(id: :desc).page(params[:page]).per(params[:per_page])
        else
          @clients = client_service.search_client(params[:search], params[:per_page])
        end
        render json: {
          clients: client_service.serialize_clients(@clients),
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

      def dde_search_client
        clients = client_service.search_client_by_name_and_gender(params[:first_name], params[:last_name], params[:gender])
        clients = client_service.serialize_clients(clients)
        if @dde_service.check_dde_status
          dde_clients = @dde_service.search_client_by_name_and_gender(params[:first_name], params[:last_name], params[:gender])
          clients = (clients + dde_clients).uniq{|key| [key[:uuid]]}
        end
        render json: clients
      end

      def search_by_name
        clients = Person.search_by_first_name(params[:first_name]) if params[:first_name].present?
        clients = Person.search_by_first_name(params[:last_name]) if params[:last_name].present?
        clients ||= []
        render json: clients
      end

      def create
        @client = ClientManagement::ClientService.create_client(client_params, params[:client_identifiers])
        render json: ClientManagement::ClientService.get_client(@client.id), status: :created
      end

      def update
        ClientManagement::ClientService.update_client(@client, client_params, params)
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

      def client_service
        ClientManagement::ClientService
      end

      def prev_days_date(date, days)
        date ||= Date.today
        date.to_date - days
      end

      def dde
        config_data = YAML.load_file("#{Rails.root}/config/application.yml")
        dde_config = config_data["dde_service"]
        raise DdeError, "DDE service configuration not found" if dde_config.nil?
        @dde_service = ClientManagement::DdeService.new(
          base_url: "#{dde_config['base_url']}:#{dde_config['port']}",
          token: '',
          username: dde_config['username'],
          password: dde_config['password']
        )
      end

      def client_params
        params.permit(client: %i[uuid],
          person: %i[first_name middle_name last_name sex date_of_birth birth_date_estimated])
      end

      def validate_params
        unless params.has_key?('client_identifiers')
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for client_identifiers"
        end
      end
    end

  end
end

module ExceptionHandler
  extend ActiveSupport::Concern
  included do 
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rails.logger.error("Record not found: #{e.message}")
      render json: {error: MessageService::RECORD_NOT_FOUND}, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: {error: e.message}, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordNotUnique do |e|
      render json: { error: e.message }, status: :conflict
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::StatementInvalid do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    rescue_from JWT::DecodeError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::ExpiredSignature do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::VerificationError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::InvalidIatError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::InvalidIssuerError do |e|
      render json: { error: e.message }, status: :unauthorized
    end
    
    rescue_from JWT::InvalidSubError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::InvalidAudError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::InvalidJtiError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::ImmatureSignature do |e|

      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::IncorrectAlgorithm do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from JWT::InvalidIatError do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    # rescue internal server errors
    # rescue_from StandardError do |e|
    #   Rails.logger.error("Internal server error: #{e.message}")
    #   render json: { error: e.message }, status: :internal_server_error
    # end
    

  end
end
class Api::V1::InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :update, :destroy]

  def index
    page, page_size, search = pagination.values_at(:page, :page_size, :search)
    if search.blank?
      data = Instrument.limit(page_size.to_i).offset((page.to_i - 1) * page_size.to_i)
    else
      filtered = Instrument.where("name LIKE ?", "%#{search}%").count
      data = Instrument.where("name LIKE ?", "%#{search}%").offset((page.to_i - 1) * page_size.to_i).limit(page_size.to_i)
    end

    total = Instrument.count    
    
    @instruments = {page: page.to_i,
                    page_size: page_size.to_i,
                    total: total.to_i,
                    filtered: filtered || 0,
                    data: payload(data.as_json)}

    render json: @instruments
  end
  
  def show
    data = payload([@instrument.as_json])[0]
    data[:supported_tests] = supported_tests
    render json: data
  end

  def create
    @instrument = Instrument.new(instrument_params)

    if @instrument.save
      render json: @instrument, status: :created, location: [:api, :v1, @instrument]
    else
      render json: { errors: @instrument.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @instrument.update(instrument_params)
      render json: @instrument
    else
      render json: { errors: @instrument.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    destroy_data = destroy_params
   
   if @instrument.update(destroy_data)
     render json: {message: 'Deletion Sucessful'}, status: :no_content and return
   else
    render json: { errors: @instrument.errors.full_messages }, status: :unprocessable_entity
   end
  end

  private

  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  def instrument_params
    params.require(:name)
    params.permit(:name, :description, :ip_address, :hostname, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end

  def pagination
    params.require([:page, :page_size])
    params.permit(:search)
    {page: params[:page], page_size: params[:page_size], search: params[:search]}
  end

  def payload(data)
    data.map { |instrument| instrument.slice('id', 'name', 'description', 'ip_address', 'hostname', 'can_perform', 'created_date')}
  end

  def destroy_params
    params.require(:retired_reason)
    {retired_reason: params[:retired_reason], retired_by: user.to_i, retired: true}
  end

  def user
    UserManagement::AuthService.jwt_token_decode(request.headers['Authorization'].split.last)['user_id']
  end

  def supported_tests
    results = Instrument.joins(instrument_test_type_mapping: :test_type)
                   .where(id: params[:id])
                   .pluck('test_types.name')

    results.join(', ')
  end
end

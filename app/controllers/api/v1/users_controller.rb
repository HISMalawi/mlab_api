class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  skip_before_action :authorize_request, only: [:login, :application_login]

  def index
    @users = User.all
    render json: @users
  end
  
  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: [:api, :v1, @user]
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  def login
    payload = UserService.login(params[:username], params[:password], params[:department])
    if payload == false
      error_message = 'User is not authorized to access this department'
      render json: {errors: [error_message]}, status: :unauthorized
    elsif payload.nil?
      error_message = 'Invalid username or password'
      render json: {errors: [error_message]}, status: :unauthorized
    else
      render json: {authorization: payload}, status: :ok
    end
  end

  def application_login
    payload = UserService.application_login(params[:username], params[:password])
    if payload.nil?
      error_message = 'Invalid username or password'
      render json: {errors: [error_message]}, status: :unauthorized
    else 
      render json: {authorization: payload}, status: :ok
    end
  end

  # TO DO TOKEN REFRESH _ 
  def refresh_token
    user = User.find()
    payload = {token: UserService::jwt_token_encode(user_id: User.current.id), expiry_time: UserService::TOKEN_VALID_TIME,
       user: UserService::find_user(User.current.id)}
    render json: {authorization: payload}, status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role_id, :person_id, :username, :password, :last_password_changed, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end

class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

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

  def current_user
    user = UserService.find_user(params[:user_id])
    if user.nil?
      render json: user.errors, status: :unprocessable_entity
    else
      render json: user, status: :ok
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role_id, :person_id, :username, :password, :last_password_changed, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end

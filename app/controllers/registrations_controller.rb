class RegistrationsController < ApplicationController
  include CurrentUserConcern
  def create
    begin
      user = User.create!(username: params['username'], name: params['name'], password: params['password'], password_confirmation: params['password_confirmation'])
      session[:user_id] = user.id
      redirect_to notes_path
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  def new
    
  end
  def edit
  end
  def update
    if BCrypt::Password.new(@current_user.password_digest) == params["password"]
      @current_user.assign_attributes(name: params[:name])
      
      if params["new_password"].present?
        @current_user.assign_attributes(password: params["new_password"])
      end

      if @current_user.valid? && @current_user.save
        redirect_to notes_path
      else
        # Handle validation errors and return a 422 status
        render json: { status: 422, message: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { status: 401, message: "Invalid password" }, status: :unauthorized
    end
  end
end
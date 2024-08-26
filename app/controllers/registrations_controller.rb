class RegistrationsController < ApplicationController
  include CurrentUserConcern
  def create
    user = User.create!(username: params['username'], name:params['name'],password: params['password'], password_confirmation: params['password_confirmation'])

    if user
      session[:user_id] = user.id
      # render json: {
      #   status: :created,
      #   user: user
      # }
      redirect_to notes_path
    else
      render json: {status: 500}
    end
  end
  def new
    
  end
  def index
    
  end
  def edit
  end
  def update
    # if @note.update(note_params)
    #   redirect_to @note
    # else
    #   render :edit, status: :unprocessable_entity
    # end
    if BCrypt::Password.new(@current_user.password_digest) == params["password"]
      @current_user.update(
        name: params[:name]
      )
      if params["new_password"] && params["new_password"].length > 0
        @current_user.update(
          password: params["new_password"]
        )
      end
    else
      error!({status: 401, message: "Invalid password"}, 401)
    end

    if @current_user.save
     redirect_to notes_path
    else
      error!({ status: 422, message: @current_user.errors.full_messages }, 422)
    end
  end
end
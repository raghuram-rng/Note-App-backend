class SessionsController < ApplicationController
  include CurrentUserConcern
  def create
     user = User.find_by(username: params["username"]).try(:authenticate, params["password"])

     if user
       session[:user_id] = user.id
      #  render json: {
      #   status: :created,
      #   logged_in: true,
      #   user: user
      #  }
      redirect_to notes_path
      else
        render json:  { status: 401 }
     end
  end
  def logged_in
    if @current_user
      render json: {
        logged_in: true,
        user: @current_user
      }
    else
      render json: {
        logged_in: false
      }
    end
  end
  def logout
    reset_session
    redirect_to new_session_path
    # render json: {status: 200, logged_out: true}
  end
  def new
    
  end
  def index
    
  end
end
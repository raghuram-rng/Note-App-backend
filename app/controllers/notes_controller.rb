class NotesController <  ApplicationController
  before_action :set_note, except: [:index, :new, :create, :search]
  before_action :require_login
  before_action :authorize_user, only: [:edit, :update, :destroy]

  include CurrentUserConcern
  def index
    if @current_user
      @notes = @current_user.notes
      @user_name = @current_user.name if @current_user
    end
  end

  def show
  end
  def new
    # @note=Note.new
    @note = @current_user.notes.build
  end

  def create
    @note = @current_user.notes.build(note_params)
    # @note=Note.new(note_params)
    puts @note.inspect
    if @note.save
      redirect_to @note, notice: 'Note was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def search
    @parameter = params[:q].downcase
    @notes = @current_user.notes.where('title ILIKE :search OR content ILIKE :search', search: "%#{@parameter}%").order(created_at: :desc)
    # @notes_title = Note.all.where("lower(title) LIKE :search",search: "%#{@parameter}%")
    # @notes_content = Note.all.where("lower(content) LIKE :search",search: "%#{@parameter}%")
  end



  def update
    if @note.update(note_params)
      redirect_to @note
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_url, notice: 'Note was successfully deleted.'
  end

  def correct_user
    @note = current_user.notes.find_by(id: params[:id])
    redirect_to notes_path, notice: "Not Authorized to edit this note" if @note.nil?
  end

  private
  def require_login
    unless current_user
      redirect_to login_path
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authorize_user
    unless @note.user_id == current_user.id
      redirect_to notes_url, alert: 'You are not authorized to perform this action.', status: :forbidden
    end
  end


  def note_params
    params.require(:note).permit(:title,:content,:user_id)
  end

  def set_note
   @note = Note.find(params[:id]) 
  end
end
class NotesController <  ApplicationController
  before_action :set_note, except: [:index, :new, :create, :search]
  # before_action :authenticate_user!, except: [:index]
  # before_action :correct_user, only: [:edit,:destroy,:update]
  include CurrentUserConcern
  def index
    if @current_user
      @notes = @current_user.notes
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
      redirect_to @note
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def search
    @parameter = params[:q].downcase
    @notes_title = Note.all.where("lower(title) LIKE :search",search: "%#{@parameter}%")
    @notes_content = Note.all.where("lower(content) LIKE :search",search: "%#{@parameter}%")
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
    redirect_to notes_path
  end

  def correct_user
    @note = current_user.notes.find_by(id: params[:id])
    redirect_to notes_path, notice: "Not Authorized to edit this note" if @note.nil?
  end

  private

  def note_params
    params.require(:note).permit(:title,:content,:user_id)
  end

  def set_note
   @note = Note.find(params[:id]) 
  end
end
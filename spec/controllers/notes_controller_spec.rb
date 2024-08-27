require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  let(:user) { User.create!(username: "testuser", password: "password", name: "Test User") }
  let(:user2) { User.create!(username: "testuser2", password: "password", name: "Test User") }
  let(:note) { Note.create!(user: user, title: "Example Title", content:"Example Content") } # Assuming you have a note factory

  before do
    # sign_in user # Devise helper method to simulate user authentication
    # User.create!(username: "testuser", password: "password", name: "Test User")
  end
  
  describe 'GET #index' do
    it 'assigns all user notes as @notes' do
      #include the note instance
      note
      get :index
      #this is @notes in the controller, assign method [note]
      expect(assigns(:notes)).to eq([note])
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested note as @note' do
      get :show, params: { id: note.id }
      expect(assigns(:note)).to eq(note)
    end

    it 'renders the show template' do
      get :show, params: { id: note.id }
      expect(response).to render_template(:show)
    end
  end


  describe 'GET #edit' do
    it 'assigns the requested note as @note' do
      get :edit, params: { id: note.id }
      expect(assigns(:note)).to eq(note)
    end

    it 'renders the edit template' do
      get :edit, params: { id: note.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) {
        { title: 'New Title', content: 'New Content', user_id: user.id }
      }

      it 'creates a new Note' do
        expect {
          post :create, params: { note: valid_attributes }
        }.to change(Note, :count).by(1)
      end

      it 'assigns a newly created note as @note' do
        post :create, params: { note: valid_attributes }
        expect(assigns(:note)).to be_a(Note)
        expect(assigns(:note)).to be_persisted
      end

      it 'redirects to the created note' do
        post :create, params: { note: valid_attributes }
        expect(response).to redirect_to(Note.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) {
        { title: '', content: '', user_id: user.id }
      }

      it 'assigns a newly created but unsaved note as @note' do
        post :create, params: { note: invalid_attributes }
        expect(assigns(:note)).to be_a_new(Note)
      end

      it 're-renders the new template' do
        post :create, params: { note: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { title: 'Updated Title' }
      }

      it 'updates the requested note' do
        put :update, params: { id: note.id, note: new_attributes }
        note.reload
        expect(note.title).to eq('Updated Title')
      end

      it 'assigns the requested note as @note' do
        put :update, params: { id: note.id, note: new_attributes }
        expect(assigns(:note)).to eq(note)
      end

      it 'redirects to the note' do
        put :update, params: { id: note.id, note: new_attributes }
        expect(response).to redirect_to(note)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) {
        { title: '' }
      }

      it 'assigns the note as @note' do
        put :update, params: { id: note.id, note: invalid_attributes }
        expect(assigns(:note)).to eq(note)
      end

      it 're-renders the edit template' do
        put :update, params: { id: note.id, note: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested note' do
      note # create the note
      expect {
        delete :destroy, params: { id: note.id }
      }.to change(Note, :count).by(-1)
    end

    it 'redirects to the notes list' do
      delete :destroy, params: { id: note.id }
      expect(response).to redirect_to(notes_url)
    end
  end

  describe 'GET #search' do
    it 'assigns the search results as @notes' do
      note
      get :search, params: { q: note.content }
      expect(assigns(:notes)).to eq([note])
    end

    it 'renders the search template' do
      get :search, params: { q: note.content }
      expect(response).to render_template(:search)
    end
  end
end
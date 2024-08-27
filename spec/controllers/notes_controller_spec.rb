# spec/controllers/notes_controller_spec.rb
require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  let(:valid_attributes) {
    { title: "Test Note", content: "This is a test note content." }
  }

  let(:invalid_attributes) {
    { title: nil, content: nil }
  }

  let(:user) { User.create!(username: 'testuser', password: 'password', name: 'Test User') }
  let(:other_user) { User.create!(username: 'otheruser', password: 'password', name: 'Other User') }

  before do
    session[:user_id] = user.id
  end

  describe "GET #index" do
    context "when user is logged in" do
      it "returns a successful response" do
        get :index
        expect(response).to be_successful
      end

      it "assigns the current user's name" do
        get :index
        expect(assigns(:user_name)).to eq(user.name)
      end
    end

    context "when user is not logged in" do
      before do
        session[:user_id] = nil
      end

      it "redirects to the login page" do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Note" do
        expect {
          post :create, params: { note: valid_attributes }
        }.to change(Note, :count).by(1)
      end

      it "redirects to the created note" do
        post :create, params: { note: valid_attributes }
        expect(response).to redirect_to(Note.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Note" do
        expect {
          post :create, params: { note: invalid_attributes }
        }.to change(Note, :count).by(0)
      end

      it "returns an unprocessable entity response" do
        post :create, params: { note: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when user is not logged in" do
      before do
        session[:user_id] = nil
      end

      it "does not create a new Note and redirects to login" do
        post :create, params: { note: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:note) { Note.create!(valid_attributes.merge(user_id: user.id)) }

    context "when user is logged in" do
      it "deletes the note" do
        expect {
          delete :destroy, params: { id: note.id }
        }.to change(Note, :count).by(-1)
      end

      it "redirects to the notes list" do
        delete :destroy, params: { id: note.id }
        expect(response).to redirect_to(notes_path)
      end
    end

    context "when user is not logged in" do
      before do
        session[:user_id] = nil
      end

      it "does not delete the note and redirects to login" do
        expect {
          delete :destroy, params: { id: note.id }
        }.not_to change(Note, :count)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when a different user tries to delete the note" do
      before do
        session[:user_id] = other_user.id
      end

      it "does not delete the note" do
        expect {
          delete :destroy, params: { id: note.id }
        }.not_to change(Note, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH/PUT #update" do
    let!(:note) { Note.create!(valid_attributes.merge(user_id: user.id)) }
    let(:new_attributes) {
      { title: "Updated Note", content: "This is updated note content." }
    }

    context "when user is logged in" do
      context "with valid parameters" do
        it "updates the requested note" do
          patch :update, params: { id: note.id, note: new_attributes }
          note.reload
          expect(note.title).to eq("Updated Note")
          expect(note.content).to eq("This is updated note content.")
        end

        it "redirects to the note" do
          patch :update, params: { id: note.id, note: new_attributes }
          expect(response).to redirect_to(note)
        end
      end

      context "with invalid parameters" do
        it "does not update the note" do
          patch :update, params: { id: note.id, note: invalid_attributes }
          note.reload
          expect(note.title).to eq("Test Note")
          expect(note.content).to eq("This is a test note content.")
        end

        it "returns an unprocessable entity response" do
          patch :update, params: { id: note.id, note: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when user is not logged in" do
      before do
        session[:user_id] = nil
      end

      it "does not update the note and redirects to login" do
        patch :update, params: { id: note.id, note: new_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when a different user tries to update the note" do
      before do
        session[:user_id] = other_user.id
      end

      it "does not update the note and returns forbidden status" do
        patch :update, params: { id: note.id, note: new_attributes }
        note.reload
        expect(note.title).not_to eq("Updated Note")
        expect(note.content).not_to eq("This is updated note content.")
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

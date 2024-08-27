require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { User.create!(username: 'testuser', password: 'password', name: 'Test User') }

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user and redirects to the notes path" do
        post :create, params: { username: user.username, password: 'password' }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(notes_path)
      end
    end

    context "with invalid credentials" do
      it "does not log in the user and returns a 401 status" do
        post :create, params: { username: user.username, password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #logged_in" do
    context "when user is logged in" do
      before do
        session[:user_id] = user.id
      end

      it "returns logged_in as true and the user object" do
        get :logged_in
        json_response = JSON.parse(response.body)
        expect(json_response['logged_in']).to be true
        expect(json_response['user']['username']).to eq(user.username)
      end
    end

    context "when user is not logged in" do
      it "returns logged_in as false" do
        get :logged_in
        json_response = JSON.parse(response.body)
        expect(json_response['logged_in']).to be false
      end
    end
  end

  describe "DELETE #logout" do
    before do
      session[:user_id] = user.id
    end

    it "logs out the user and redirects to the new session path" do
      delete :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "GET #index" do
  it "raises an error for missing route" do
    expect {
      get :index
    }.to raise_error(ActionController::UrlGenerationError)
  end
end
end

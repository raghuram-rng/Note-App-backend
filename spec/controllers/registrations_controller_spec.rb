# spec/controllers/registrations_controller_spec.rb
require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:user) { User.create!(username: 'testuser', name: 'Test User', password: 'password', password_confirmation: 'password') }

  describe "POST #create" do
    context "with invalid parameters" do
      it "does not create a user and returns a 500 status" do
        post :create, params: { username: 'newuser', name: 'New User', password: 'password', password_confirmation: 'wrongpassword' }
        expect(User.exists?(username: 'newuser')).to be false
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['message']).to include("Password confirmation doesn't match Password")
      end
    end

    context "with invalid parameters" do
      it "does not create a user and returns a 500 status" do
        post :create, params: { username: 'newuser', name: 'New User', password: 'password', password_confirmation: 'wrongpassword' }
        expect(User.exists?(username: 'newuser')).to be false
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
  
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end
end
require "rails_helper"

RSpec.describe "Grape API", type: :request do

  #create a test user for the session
  let(:user) { User.create!(username: "User1", password: "password", name: "Test User") }
  let(:note) { Note.create!(user_id: user.id, title: "Test Title", content: "Test Content") }

  before do
    # Simulate a logged-in user by setting the session
    post "/api/v1/sessions", params: { username: user.username, password: "password" } 
  end

  describe "GET /api/v1/notes" do
    it "returns a successful response" do
      get "/api/v1/notes"  
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /api/v1/sessions" do
    it "logs in a user" do
      #this method print out the user object in ruby hash format
      # p JSON.parse(user.to_json)
      post "/api/v1/sessions", params: { username: user.username, password: "password" }
      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)).to include({
        "status" => "created",
        "logged_in" => true,
        "user" => JSON.parse(user.to_json)
      })
    end

    it 'fails to log in with incorrect password' do
      post '/api/v1/sessions', params: { username: user.username, password: 'wrong_password' } 
      expect(response).to have_http_status(401)
    end
  end

  describe 'Registrations' do

    describe 'POST /api/v1/registrations' do
      it 'registers a new user' do
        post '/api/v1/registrations', params: {username: 'newuser', password: 'newpassword', password_confirmation: 'newpassword', name: 'New User' } 
        expect(response).to have_http_status(:created)
      end
    end

  end

  describe 'Notes' do

    describe 'GET /api/v1/notes' do
      it 'returns all notes for the current user' do
        get '/api/v1/notes'
        expect(response).to have_http_status(200)
      end
    end

    describe 'POST /api/v1/notes' do
      it 'creates a new note' do
        post '/api/v1/notes', params: {title: 'Note Title', username: 'newuser', password: 'newpassword', content: "Note Content" } 
        expect(response).to have_http_status(201)
      end
    end

    describe 'PUT /api/v1/notes/:id' do

      it 'attempts updates a note' do
        put "/api/v1/notes/#{note.id + 1}", params: { title: 'Updated Title' }
        expect(response).to have_http_status(404)
      end

      it 'updates a note' do
        put "/api/v1/notes/#{note.id}", params: { title: 'Updated Title',content: "Updated Content"}
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['note']['title']).to eq('Updated Title')
      end 

    end

    describe 'DELETE /api/v1/notes/:id' do
      it 'deletes a note' do
        delete "/api/v1/notes/#{note.id}"
        expect(response).to have_http_status(200)
      end
    end

  end

end
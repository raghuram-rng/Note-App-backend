module Test
  class Base < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    helpers do
      def set_current_user
        #if current user is nil, then send error response
        if env['rack.session'][:user_id]
          @current_user = User.find(env['rack.session'][:user_id])  
        else
          error!('Unauthorized', 401)
        end 

        def current_user
          @current_user
        end
      end
    end

    resources :sessions do
      desc "Login route" 
      post do
        user = User.find_by(username: params["username"])

        if user && user.authenticate(params["password"])
          # User is authenticated and valid

          env['rack.session'][:user_id] = user.id
          {
            status: :created,
            logged_in: true,
            user: user
          }
        elsif user
          # User exists but authentication failed
          error!({ status: 401, message: "Invalid password" }, 401)
        else
          # User does not exist
          error!({ status: 401, message: "User does not exist" }, 401)
        end
      end
    end

    resources :registrations do

      desc "Register a new user" 
      post do
        # p params
        user = User.create(
          username: params['username'],
          password: params['password'],
          password_confirmation: params['password_confirmation'],
          name: params['name']
        )
        if user.valid?
          env['rack.session'][:user_id] = user.id
          # p env['rack.session']
          {
            status: :created,
            user: user
          }
        else
          error!({ status: 401, message: "User already exists" }, 401)
        end
      end

      before { set_current_user }

      desc 'Update current user details'
      params do
        optional :username, type: String, desc: 'New username'
        requires :password, type: String, desc: 'Current password'
        requires :name, type: String, desc: 'New display name'
        optional :new_password, type: String, desc: 'New password'
      end

      put do
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
          { status: :updated, user: @current_user }
        else
          error!({ status: 422, message: @current_user.errors.full_messages }, 422)
        end
      end
    end

    #for credentials - get, post, edit, delete
    resources :notes do
      before { set_current_user }

      desc "Return all notes of the current user"
      get  do
        Note.where(user_id: current_user.id).order(created_at: :desc)
      end


      desc "Create a new note"
      post do
        note = Note.create(
          user_id: current_user.id ,
          title:params['title'] ,
          content:params['content'], 
        )
        if note.valid?
          {
            status: :created,
          }
        else
          error!({ status: 500, message: credential.errors.full_messages }, 500)
        end
      end

      desc 'Update a note'
      params do
        requires :id, type: Integer, desc: 'Note ID'
        optional :title, type: String, desc: 'Note title'
        optional :content, type: String, desc: 'Note Content'
      end
      put ':id' do
        id = params[:id].to_i
        note = Note.find_by(id: id, user_id: current_user.id)

        if note
          if note.update(declared(params, include_missing: false))
            { status: :updated, message: "Note updated", note: note }
          else
            error!({ status: 422, message: "Unable to update note", errors: note.errors.full_messages }, 422)
          end
        else
          error!({ status: 404, message: "Note not found" }, 404)
        end
      end

      before { set_current_user }
      desc 'Search notes'
      params do
        requires :query, type: String, desc: 'Search query'
      end
      get :search do
        parameter = params[:query].downcase
        note=Note.where(user_id: current_user.id).order(created_at: :desc)
        notes = note.where('title ILIKE :search OR content ILIKE :search', search: "%#{parameter}%").order(created_at: :desc)
        notes
      end

      desc 'Delete a note'
      params do
        requires :id, desc: 'Note ID'
      end
      delete ':id' do
        id = params[:id].to_i
        note = Note.find_by(id: id, user_id: current_user.id)
        deleted = note
        if note
          note.destroy
          { status: :deleted, message: "Note deleted" , note: deleted}
        else
          error!({ status: 404, message: "Note not found" }, 404)
        end
      end
    end
  end
end

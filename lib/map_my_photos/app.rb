module MapMyPhotos
  class App < Sinatra::Base
    set :root, MapMyPhotos.root
    enable :sessions

    configure :development do
      register Sinatra::Reloader
    end

    use OmniAuth::Builder do
      provider :instagram, MapMyPhotos.config["INSTAGRAM_CLIENT_ID"], MapMyPhotos.config["INSTAGRAM_CLIENT_SECRET"]
    end

    get '/' do
      erb :index
    end

    get '/terms' do
      erb :terms
    end

    get '/privacy' do
      erb :privacy
    end

    get '/auth/instagram/callback' do
      user = MapMyPhotos::User.create(request.env["omniauth.auth"])
      session[:created_slideshow] = true
      redirect to("/#{user.nickname}")
    end

    get '/:nickname' do
      @user = MapMyPhotos::User.find_access_token_by_nickname params[:nickname]

      if @user
        Instagram.access_token = @user.access_token
        @photos = Instagram.user_recent_media(count: 50)
        erb :show
      else
        @nickname = params[:nickname]
        erb :bummer
      end
    end

  end
end
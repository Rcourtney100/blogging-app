require 'sinatra'
require 'rubygems'
require 'sinatra/activerecord'
require './models'
require 'sinatra/flash'

set :database, 'sqlite3:test.sqlite3'
enable :sessions

def current_user
	if session[:user_id]
		@current_user = User.find(session[:user_id])
	end
end	

get '/' do
	@posts = Post.order(id: :desc).take(10)
	erb :home
end	

get '/log_in' do
	erb :log_in
end	

post '/log_in' do
	@user = User.where(username: params[:username]).first
		if @user.password == params[:password]
			session[:user_id] = @user.id
			current_user
			redirect '/profile'
		else
			redirect  '/log_in_failed'
		end
end

get '/sign_up' do
	erb :sign_up
end

post '/sign_up' do
	@user = User.where(username: params[:username]).first
	if @user.nil?
		@user = User.create(username: params[:username], password: params[:password], email: params[:email])
		flash[:notice] = 'Congratulations! You have successfully signed up and edited your profile.'	
		@profile = Profile.create(fname: params[:fname], lname: params[:lname])
		@user.profile = @profile
		@user.save
		erb :edit_profile
	else
		flash[:alert] = 'The username: #{params[:username] is already in use'
		redirect '/sign_up_failed'
	end
		session[:user_id] = @user.id
		current_user
		erb :edit_profile
end	

get '/sign_up_failed' do
	erb :sign_up_failed
end	

get '/success' do
	erb :success
end

get '/log_in_failed' do
	erb :sign_in_failed
end

post '/login_success' do
	erb :success
end

get '/log_out' do
	session.clear
	erb :log_in
end

get '/profile' do 
	current_user
	@posts = current_user.posts
	erb :profile
end	


post '/user/create' do
	@user = User.new(name: params['name'],email: params['email'])
	@user.save
	redirect "/users/#{@user.id}"
end

get '/edit_profile' do
	erb :edit_profile

end

post '/edit_profile' do
	current_user
	current_user.profile.update(fname:params[:fname], lname:params[:lname])
	erb :edit_profile
end	

post '/new_profile' do
  current_user
  params.each do |type, value|
    if value == ""
      params.except!(type)
      puts params
    else
    @current_user.profile.update({type => value})
    end
  end
  redirect '/profile'
end

post '/delete_profile' do
	current_user
	current_user.destroy
	erb :home
end

get '/:username' do
	@user = User.find_by(name: params[:name])
	@profile = Profile.find_by(user_id: @user.id)
	@posts = Post.where(user_id: @user.id)
	erb :user
end

get '/users' do
	@users = User.all
	erb :users
end

get '/user' do
	@users = User.all
	erb :user
end		

post '/post' do
	current_user
	if params[:post] != ""
		current_user.posts << Post.create(content: params[:post])
	end
	redirect '/profile'
end


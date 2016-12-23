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

get '/users' do
	@users=User.all
	erb :users
end	

get '/' do 
	if session[:user_id] 

		@user = User.find(session[:user_id])
	end

	@display_text = "Welcome to my Blog"
	erb :home
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

# update

get '/user/:id/edit' do
	@user= User.find(params['id'])
	erb :edit_user

end

post '/user/:id/update' do
	@user = User.find(params['id'])
	@user.update(name: params['name'], email: params['email'])
	redirect :user
end	

get '/user/new' do 
	erb :new_user
end

post '/new_user' do
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

# delete
post '/user/:id/delete' do
	@user = User.find(params['id'])
	@user.destroy
	session[:user_id]=nil
	redirect "/"
end

# signin

get '/sign_in' do
	erb :sign_in
end	

post '/sign_in' do
	@user = User.where(username: params[:username]).first
		if @user.password == params[:password]
			session[:user_id] = @user.id
			current_user
			redirect '/profile'
		else
			flash[:alert] = "Sign in Failed"
		end
end

# login	
post '/login' do
	@user = User.where(email: params['email']).first
	if @user && @user.password==params['password']
		session[:user_id] = @user.id
		flash[:notice] = "You have successfully logged in."
		redirect "/users/#{session[:user_id]}"
	else
		flash[:alert] = "You were not able to sign in."
		redirect '/sign_in'	
end	
end

#read
get '/user/:id' do
	if current_user.id==params['id']
		@user = User.find(params['id'])
		erb :user
	else
		redirect '/'
	end
end			

#logout
post '/logout' do
	session[:user_id]=nil
	redirect '/'
end	

post '/sign_up' do
	@user = User.where(username: params[:username]).first
	if @user.nil?
		@user = User.create(username: params[:username], password: params[:password], email: params[:email])
		flash[:notice] = 'Congratulations! You have successfully signed up and edited your profile.'	
		@profile = Profile.create(fname: params[:fname], city: params[:city], birthday: params[:birthday], lname: params[:lname])
		@user.profile = @profile
		@user.save
		erb :edit_profile
	else
		flash[:alert] = 'The username: #{params[:username] has been taken'
		redirect '/sign_up_failed'
	end
		session[:user_id] = @user.id
		current_user
		erb :edit_profile
end


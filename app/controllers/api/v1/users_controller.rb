 class Api::V1::UsersController < ApplicationController
 	def create
 		user_params = {
 			username: params[:username],
 			password: params[:password],
 			user_type: params[:type],
 			email: params[:email],
 			description: params[:description],
 			subjects: params[:subjects],
 			first_name: params[:firstName],
 			last_name: params[:lastName]
 			teacher_key: params[:teacherKey]
 		}

 		user = User.new(user_params)
	    if user.save
	      payload = {user_id: user.id}

	      render json: {user: user, jwt: issue_token(payload), success: "Welcome to Athena, #{user.username}"}
	    else
	      render json: {failure: "Something went wrong! Sign up failed!"}
	    end
 	end
 end
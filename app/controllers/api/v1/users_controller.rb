 class Api::V1::UsersController < ApplicationController
 	def create
 		

 		user_params = {
 			username: params[:username],
 			password: params[:password],
 			user_type: params[:type],
 			email: params[:email],
 			description: params[:description],
 			subjects: params[:subjects].join("~*~"),
 			first_name: params[:first_name],
 			last_name: params[:last_name]
 		}

 		@user = User.new(user_params)
	    if @user.save
	      payload = {user_id: @user.id}

	      render json: {user: @user, jwt: issue_token(payload), success: ""}
	    else
	      render json: @user.errors.messages
	    end
 	end
 end
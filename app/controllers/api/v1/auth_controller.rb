 class Api::V1::AuthController < ApplicationController
	def create
		user = User.find_by(username: params[:username])
		if user && user.authenticate(params[:password])
			payload = {user_id: user.id}
			token = issue_token(payload)
			render json: {user: user, jwt: token, success: "Welcome back, #{user.username}"}
		else
			render json: {failure: "Signin failed! Invalid username or password!"}
		end
	end

	def get_user
		if current_user 
			render json: {user: current_user, success: "Worked!"}
		else
			render json: {failure: "Something went wrong! Oops!"}
		end
	end
 end

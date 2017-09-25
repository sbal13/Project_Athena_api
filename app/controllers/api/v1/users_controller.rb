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
 			last_name: params[:lastName],
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

 	def add_teacher
 		teacher = User.find_by(teacher_key: params[:teacher_key])

 		if !TeacherStudent.find_by(teacher: teacher, student: current_user)
	 		new_teacher_student = TeacherStudent.new(teacher: teacher, student:current_user)
	 		
	 		if new_teacher_student.save
	 			render json: {teacher: teacher, success: "Successfully added teacher"}
	 		else
	 			render json: {failure: "Something went wrong! Please check your teacher key! (case sensitive)"}
	 		end
	 	else
	 		render json: {failure: "You've already added this teacher!"}
	 	end
 	end

 	def show
 		user = User.find(params[:id])

 		if user
 			if (user.user_type == "teacher")
 				render json: {user: user, relations: user.students, success: "Successfully loaded user!"}
 			elsif (user.user_type == "student")
 				 render json: {user: user, relations: user.teachers, success: "Successfully loaded user!"}
 			end	
 		else 
 			render json: {failure: "User not loaded!"}
 		end
 	end

 	def get_teachers
 		student = User.find(params[:id])
 		if student
 			render json: {teachers: student.teachers, success: "Successfully obtained student's teachers!"}
 		else
 			render json: {failure: "Student not found!"}
 		end

 	end 	

 	def get_students
 		teacher = User.find(params[:id])
 		if teacher
 			render json: {students: teacher.students, success: "Successfully obtained teacher's students!"}
 		else
 			render json: {failure: "Teacher not found!"}
 		end

 	end


 end
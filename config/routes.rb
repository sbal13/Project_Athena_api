Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users
			resources :assignments
			post '/login', to: 'auth#create'
			post '/signup', to: 'users#create'
			get '/getcurrentuser', to: 'auth#get_user'
			post '/submitassignment/:id', to: 'assignments#submit'
			post '/addteacher', to: 'users#add_teacher'
			get '/users/:id/assignments', to: 'assignments#teacher_assignments'
			get '/users/:id/assignedassignments', to: 'assignments#student_assignments'
			get '/users/:id/teachers', to: 'users#get_teachers'
			get '/users/:id/students', to: 'users#get_students'
			get '/users/:id/studentsassignments', to: 'assignments#all_student_assignments'
			get '/submitted/:id', to: 'assignments#submitted_assignment'
			post '/assignments/assign', to: 'assignments#assign_assignment'
			post '/submitted/:id/finalize', to: 'assignments#finalize_submission'
		end
	end
end

Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users
			resources :assignments
			post '/login', to: 'auth#create'
			post '/signup', to: 'users#create'
			get '/getcurrentuser', to: 'auth#get_user'
			post '/submitassignment/:id', to: 'assignments#submit'
		end
	end
end

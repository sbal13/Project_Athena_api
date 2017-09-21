Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :users
			post '/login', to: 'auth#create'
			post '/signup', to: 'users#create'
			get '/getcurrentuser', to: 'auth#get_user'
		end
	end
end

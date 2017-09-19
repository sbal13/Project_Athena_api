class User < ApplicationRecord
	has_many :assignments
	has_many :questions, through: :assignments


	has_secure_password
	validates :username, :email, uniqueness: true
end

class Assignment < ApplicationRecord
	belongs_to :teacher, class_name: "User"
	has_many :questions
	has_many :issued_assignments
	has_many :students, through: :issued_assignments, class_name: "User"
end

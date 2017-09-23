class User < ApplicationRecord
	has_many :assignments, foreign_key: "teacher_id"
	has_many :questions, through: :assignments
	has_many :issued_assignments, foreign_key: "student_id"


	has_many :teacher_students

	has_many :students, through: :teacher_students, foreign_key: "teacher_id"
	has_many :teachers, through: :teacher_students, foreign_key: "student_id"


	has_secure_password
	validates :username, :email, uniqueness: true
	validates :username, :email, presence: true

	with_options if: :teacher? do |teacher|
		teacher.validates :teacher_key, presence: true
		teacher.validates :teacher_key, uniqueness: true
	end

	def teacher?
		type == "teacher"
	end
	
end

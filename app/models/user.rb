class User < ApplicationRecord
	has_many :assignments, foreign_key: "teacher_id"
	has_many :questions, through: :assignments
	has_many :issued_assignments, foreign_key: "student_id"


	has_many :classes, foreign_key: "student_id", class_name: "TeacherStudent"
	has_many :classrooms, foreign_key: "teacher_id", class_name: "TeacherStudent"

	has_many :students, through: :classrooms
	has_many :teachers, through: :classes


	has_secure_password
	validates :username, :email, uniqueness: true
	validates :username, :email, presence: true

	with_options if: :teacher? do |teacher|
		teacher.validates :teacher_key, presence: true
		teacher.validates :teacher_key, uniqueness: true
	end

	def teacher?
		:type == "teacher"
	end
	
end

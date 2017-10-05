# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

SUBJECTS =  [
		"english literature",
		"math",
		"chemistry",
		"biology",
		"writing",
		"grammar",
		"physics",
		"foreign language",
		"history"
	]
GRADES = [
			"1st",
			"2nd",
			"3rd",
			"4th",
			"5th",
			"6th",
			"7th",
			"8th",
			"9th",
			"10th",
			"11th",
			"12th",
			"college"
		]

5.times do |x|
	User.create(first_name: Faker::Name.first_name,
	last_name: Faker::Name.last_name,
	description: Faker::ChuckNorris.fact,
	username: "teacher#{x}",
	password: "123",
	subjects: SUBJECTS.sample(3),
	email: Faker::Overwatch.hero.gsub(/\s/, "_") + (0...99).to_a.sample.to_s + "@hotmail.com",
	user_type: "teacher",
	teacher_key: Faker::Cat.unique.name)

	User.create(first_name: Faker::Name.first_name,
	last_name: Faker::Name.last_name,
	description: Faker::ChuckNorris.fact,
	username: "student#{x}",
	password: "123",
	subjects: SUBJECTS.sample(3),
	email: Faker::Overwatch.hero.gsub(/\s/, "_") + (0...99).to_a.sample.to_s + "@hotmail.com",
	user_type: "student")
end

User.where(user_type: "teacher").each do |teacher|
	token = JSON.parse(RestClient.get("https://opentdb.com/api_token.php?command=request"))["token"]

	science_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=17&type=multiple&token=#{token}"))["results"]
	history_questions =	JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=23&type=multiple&token=#{token}"))["results"]
	biology_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=27&type=multiple&token=#{token}"))["results"]
	english_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=10&type=multiple&token=#{token}"))["results"]
	math_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=19&type=multiple&token=#{token}"))["results"]
	geography_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=22&type=multiple&token=#{token}"))["results"]
	politics_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=24&type=multiple&token=#{token}"))["results"]
	mythology_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=20&type=multiple&token=#{token}"))["results"]

	all_questions = [{topic: "Chemistry", questions: science_questions}, 
					{topic: "History", questions: history_questions},
					{topic: "History", questions: geography_questions},
					{topic: "History", questions: politics_questions},
					{topic: "History", questions: mythology_questions},
					{topic: "Math", questions: math_questions},
					{topic: "Biology", questions: biology_questions},
					{topic: "English", questions: english_questions}]
	

	#/--- Create assignments

	all_questions.each do |question_set|
		assignment = Assignment.new(
	 				difficulty: 3,
	 				subject: "#{question_set[:topic]}",
	 				description: Faker::Lorem.paragraph,
	 				assignment_type: "multiple choice",
	 				grade: GRADES.sample,
	 				timed: [true,false].sample,
	 				time: 10,
	 				title: "#{question_set[:topic]} test " + (0...99).to_a.sample.to_s,
	 				teacher: teacher,
	 				creator: teacher,
	 				protected: [true,false].sample 
	 			)
		if assignment.save
			questions = question_set[:questions]

			question_models = questions.map do |question|
					question["incorrect_answers"] << question["correct_answer"]
		 			new_question = Question.create(
		 				question_type: "multiple choice",
		 				question: question["question"],
		 				answer: question["correct_answer"],
		 				choices: question["incorrect_answers"],
		 				point_value: 10,
		 				assignment: assignment
		 			)

		 		end

		 		Question.create(
	 				question_type: "open ended",
	 				question: "This is open ended question",
	 				point_value: 20,
	 				assignment: assignment)

		 		Question.create(
	 				question_type: "essay",
	 				question: "This is an essay question",
	 				point_value: 50,
	 				assignment: assignment)

		end

		assignment.update(total_points: assignment.questions.pluck(:point_value).reduce(:+))
	end

	#/--- Create student-teacher relations

	User.where(user_type: "student").sample(3).each do |student|
		TeacherStudent.create(student: student, teacher: teacher)
	end
end

User.where(user_type: "student").each do |student|
	all_assignments = []
	student.teachers.each do |teacher|
		all_assignments.concat(teacher.assignments)
	end
	#/--- Doing assignment
	all_assignments.sample((all_assignments.length*0.8).floor).each do |assignment|
		questions = assignment.questions
		final_answers = []
		total_points = 0
		point_array = []

		#/--- Answering questions
		questions.each do |question|

			student_answer = ""
			if question.question_type == 'multiple choice'
				student_answer = question.choices.sample
				
				if student_answer == question.answer
					point_array << question.point_value
				else
					point_array << 0
				end
			else 
				student_answer = Faker::Lorem.paragraph
				point_array << rand(0..question.point_value)
			end

			final_answers << student_answer
		end

		total_points = point_array.reduce(:+)


		assigned_date = (DateTime.now - 30) + rand(0..60)
		assignment_length = rand(2..15)
		due_date = assigned_date + assignment_length
		finalized_date = assigned_date + rand(1..assignment_length)


		IssuedAssignment.create(
				student: student,
				assignment: assignment,
				status: "Graded",
				given_answers: final_answers,
				final_score: total_points,
				teacher_comments: Faker::Lorem.paragraph,
				question_points: point_array,
				assigned_date: assigned_date,
				finalized_date: finalized_date,
				due_date: due_date
			)
	end
end






# 2b1bb9013ca2014a1f6ce97b7e4f10b5fc22ce1b7bf59fdd2d39a11ec55b388d
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
	token = "0a5f600fc0ba417659f4ef80fe3ea55accd4e38b6ed1d93b85de42a6bbd500b6"

	science_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=17&type=multiple&token=#{token}"))["results"]
	history_questions =	JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=23&type=multiple&token=#{token}"))["results"]
	biology_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=27&type=multiple&token=#{token}"))["results"]
	english_questions = JSON.parse(RestClient.get("https://opentdb.com/api.php?amount=5&category=10&type=multiple&token=#{token}"))["results"]

	all_questions= [{topic: "Science", questions: science_questions}, 
					{topic: "History", questions: history_questions},
					{topic: "Biology", questions: biology_questions},
					{topic: "English", questions: english_questions}]


	all_questions.each do |question_set|
		assignment = Assignment.new(
	 				difficulty: 3,
	 				subject: "#{question_set[:topic]}",
	 				description: "nuff' said",
	 				assignment_type: "multiple choice",
	 				grade: "10th",
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
		 				question: question["question"],
		 				answer: question["correct_answer"],
		 				choices: question["incorrect_answers"],
		 				point_value: 10,
		 				assignment: assignment
		 			)
		 		end
		end

		assignment.update(total_points: assignment.questions.pluck(:point_value).reduce(:+))



	end
end



# 2b1bb9013ca2014a1f6ce97b7e4f10b5fc22ce1b7bf59fdd2d39a11ec55b388d
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
	description: Faker::Lorem.paragraph,
	username: "teacher#{x}",
	password: "123",
	subjects: SUBJECTS.sample(3),
	email: Faker::Overwatch.hero.gsub(/\s/, "_") + (0...99).to_a.sample.to_s + "@hotmail.com",
	user_type: "teacher",
	teacher_key: Faker::Zelda.unique.character)

	User.create(first_name: Faker::Name.first_name,
	last_name: Faker::Name.last_name,
	description: Faker::Lorem.paragraph,
	username: "student#{x}",
	password: "123",
	subjects: SUBJECTS.sample(3),
	email: Faker::Overwatch.hero.gsub(/\s/, "_") + (0...99).to_a.sample.to_s + "@hotmail.com",
	user_type: "student")
end
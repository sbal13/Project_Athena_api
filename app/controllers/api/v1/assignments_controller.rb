 class Api::V1::AssignmentsController < ApplicationController
 	def create
 		assignment = Assignment.new(
 				difficulty: params[:difficulty],
 				subject: params[:subject],
 				description: params[:description],
 				assignment_type: params[:assignmentType],
 				grade: params[:grade],
 				timed: params[:timed],
 				time: params[:time],
 				title: params[:title],
 				teacher: current_user,
 				creator: current_user,
 				protected: params[:protected]
 			)

 		if assignment.save 
 			params[:questions].map do |question|
	 			
	 			if question[:questionType] === "multiple choice"
		 			Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				answer: question[:answer],
		 				choices: question[:choices],
		 				point_value: question[:points],
		 				assignment: assignment
		 			)
		 		else
		 			Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				point_value: question[:points],
		 				assignment: assignment
		 			)
		 		end
	 		end

	 		assignment.update(total_points: assignment.questions.pluck(:point_value).reduce(:+))

 			render json: {assignment: {details: assignment, creator: assignment.creator}, success: "Test successfully saved"}
 		else
 			render json: {failure: "Oops! Something went wrong with saving your test!"}
 		end
 	end

 	def edit_assignment
 		old_assignment = Assignment.find(params[:id])
 		historical_assignment = nil
 		
 		if old_assignment.issued_assignments.length > 0
	 		historical_assignment = Assignment.create(
	 				difficulty: old_assignment.difficulty,
	 				subject: old_assignment.subject,
	 				description: old_assignment.description,
	 				assignment_type: old_assignment.assignment_type,
	 				grade: old_assignment.grade,
	 				timed: old_assignment.timed,
	 				time: old_assignment.time,
	 				title: old_assignment.title,
	 				teacher: current_user,
	 				creator: old_assignment.creator,
	 				protected: old_assignment.protected,
	 				total_points: old_assignment.total_points,
	 				historical: true
	 			)
	 		old_assignment.questions.sort_by{|question| question.id}.reverse.each do |question|
	 			# question.update(assignment: historical_assignment)
	 			historical_assignment.questions << question
	 		end
	 		old_assignment.questions = []

	 		old_assignment.issued_assignments.each do |issued|
	 			# issued.update(assignment: historical_assignment)
	 			historical_assignment.issued_assignments << issued
	 		end

	 		old_assignment.issued_assignments = []

	 		old_assignment.save

	 		old_assignment.update(
				difficulty: params[:difficulty],
				subject: params[:subject],
				description: params[:description],
				assignment_type: params[:assignmentType],
				grade: params[:grade],
				timed: params[:timed],
				time: params[:time],
				title: params[:title],
				protected: params[:protected]
			)

			params[:questions].map do |question|
				new_question = nil
				if question[:questionType] === "multiple choice"
		 			new_question = Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				answer: question[:answer],
		 				choices: question[:choices],
		 				point_value: question[:points],
		 				assignment: old_assignment
		 			)
		 		else
		 			new_question = Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				point_value: question[:points],
		 				assignment: old_assignment
		 			)
		 		end
		 		old_assignment.questions << new_question
			end

			old_assignment.update(total_points: old_assignment.questions.pluck(:point_value).reduce(:+))

			render json: {edited_assignment: {details: old_assignment, creator: old_assignment.creator}, historical_assignment: {details: historical_assignment, creator: historical_assignment.creator}, success: "Test successfully saved"}

	 	else 
	 		old_assignment.questions.destroy_all
 		

			old_assignment.update(
				difficulty: params[:difficulty],
				subject: params[:subject],
				description: params[:description],
				assignment_type: params[:assignmentType],
				grade: params[:grade],
				timed: params[:timed],
				time: params[:time],
				title: params[:title],
				protected: params[:protected]
			)

			params[:questions].map do |question|
				new_question = nil
				if question[:questionType] === "multiple choice"
		 			new_question = Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				answer: question[:answer],
		 				choices: question[:choices],
		 				point_value: question[:points],
		 				assignment: old_assignment
		 			)
		 		else
		 			new_question = Question.create(
		 				question_type: question[:questionType],
		 				question: question[:question],
		 				point_value: question[:points],
		 				assignment: old_assignment
		 			)
		 		end
		 		old_assignment.questions << new_question
			end

			old_assignment.update(total_points: old_assignment.questions.pluck(:point_value).reduce(:+))
			render json: {edited_assignment: {details: old_assignment, creator: old_assignment.creator}, success: "Test successfully saved"}

		end


 	end


 	def index
 		assignments = Assignment.all.where(historical: false)
 		assignments = assignments.map do |assignment|
 			questions = assignment.questions.sort_by{|question| question.id}

 			{details: assignment, creator: assignment.teacher, questions: questions}
 		end
 		render json: {assignments: assignments, success: "Successfully obtained assignments"}
 	end


 	def show
 		assignment = Assignment.find(params[:id])

 		if assignment
 			questions = assignment.questions.sort_by{|question| question.id}
 			render json: {assignment: {details: assignment, creator: assignment.creator, questions: questions}, success: "Successfully found #{assignment.id}"}
 		else
 			render json: {failure: "Oops! Didn't find that assignment!"}
 		end
 	end

 	def submit
 		
 		issued_assignment = IssuedAssignment.find_by(assignment_id: params[:id], student_id: current_user.id)
 		assignment = Assignment.find(params[:id])

 		total_score = 0
 		final_points_array = []

 		assignment.questions.each_with_index do |question, index|
 			if question.question_type == "multiple choice"
 				if question.answer == params[:answers][index]
 					total_score += question.point_value 
 					final_points_array << question.point_value
 				else 
 					final_points_array << 0
 				end
 			else
 				final_points_array << 0
 			end
 		end


 		if assignment.questions.all?{|question| question.question_type == "multiple choice"}
 			status = "Graded"
 			final_date = DateTime.now
 		else 
 			status = "Submitted"
 			final_date = nil
 		end



 		if issued_assignment.update(final_score: total_score, question_points: final_points_array, status: status, given_answers: params[:answers], finalized_date: final_date)
 			render json: {assignment: issued_assignment, success: "Successfully submitted"}
 		else
 			render json: {failure: "Submission failed!"}
 		end

 	end

 	def teacher_assignments
 		teacher = User.find(params[:id])

 		assignments = teacher.assignments.map do |assignment|
 			{details: assignment, creator: assignment.creator}
 		end

 		if teacher
 			render json: {assignments: assignments, success: "Successfully obtained teacher's assignments!"}
 		else
 			render json: {failure: "Didn't find that teacher!"}
 		end
 	end

  	def student_assignments
 		student = User.find(params[:id])

 		assignments = student.issued_assignments.map do |issued|
 			{issued_assignments: {assignment_details: issued.assignment, details: issued}}
 		end

 		if student
 			render json: {assignments: assignments, success: "Successfully obtained student's assignments!"}
 		else
 			render json: {failure: "Didn't find that student!"}
 		end
 	end

 	def all_student_assignments
 		teacher = User.find(params[:id])
 		students = teacher.students

 		issued_assignments = students.map do |student|
 			student.issued_assignments
 		end.flatten.select do |assignment|
 			assignment.assignment.teacher_id == teacher.id
 		end

 		final = issued_assignments.map do |issued|
 			{issued_assignments: {assignment_details: issued.assignment, details: issued}}
 		end
 		
 		 if teacher
 			render json: {assignments: final, success: "Successfully obtained student's assignments!"}
 		else
 			render json: {failure: "Didn't find that student!"}
 		end
 	end

 	def assign_assignment
 		all_issued = []
 		messages = []

 		params[:students].each do |student_id|
 			 student = User.find(student_id)

 			 if student
	 			 params[:assignments].each do |assignment_id|
	 			 	assignment = Assignment.find(assignment_id)

	 			 	if assignment
		 			 	issued_assignment =  IssuedAssignment.new(student: student, assignment: assignment, status: "Pending", assigned_date: DateTime.now, due_date: params[:due_date])

		 			 	if IssuedAssignment.find_by(assignment_id: assignment.id, student_id: student.id)
		 			 		messages << "You've already assigned #{assignment.title} to #{student.username}!"
		 			 	else
					 		if issued_assignment.save
					 			all_issued << {issued_assignments: {assignment_details: assignment, details: issued_assignment}}
					 		else
					 			messages << "Failed to save assignment!"
					 		end
					 	end

				 	else 
			 			messages << "Failed to locate assignment!"
				 	end
			 	end
			 else 
			 	messages << "Failed to locate student!"
			 end
 		end

 		render json: {assignments: all_issued, messages: messages}

 	end

 	def submitted_assignment
 		issued_assignment = IssuedAssignment.find(params[:id])
 		assignment = issued_assignment.assignment
 		if issued_assignment 
 			questions = assignment.questions.sort_by{|question| question.id}
 			render json: {issued_assignment: {assignment_details: assignment, questions: questions, details: issued_assignment}, success: "Successfully retrieved submitted assignment!"}
 		else
 			render json: {failure: "Failed to locate submitted assignment!"}
 		end

 	end

 	def finalize_submission
 		issued_assignment = IssuedAssignment.find(params[:id])

 		if issued_assignment.update(question_points: params[:final_points], teacher_comments: params[:comments], final_score:  params[:final_points].reduce(:+), finalized_date: DateTime.now, status: "Graded")
 			render json: {assignment: issued_assignment, success: "Updated assignment!"}
 		else
 			render json: {failure: "Update of assignment failed!"}
 		end
 	end
 	def copy
 		assignment = Assignment.find(params[:id])

 		new_assignment = Assignment.new(
 				difficulty: assignment.difficulty,
 				subject: assignment.subject,
 				description: assignment.description,
 				assignment_type: assignment.assignment_type,
 				grade: assignment.grade,
 				timed: assignment.timed,
 				time: assignment.time,
 				title: assignment.title + " (copy)",
 				teacher: current_user,
 				creator: assignment.creator,
 				protected: assignment.protected,
 				total_points: assignment.total_points
 			)

 		if new_assignment.save 
 			assignment.questions.reverse_each do |question|
	 			
	 			if question.question_type === "multiple choice"
		 			Question.create(
		 				question_type: question.question_type,
		 				question: question.question,
		 				answer: question.answer,
		 				choices: question.choices,
		 				point_value: question.point_value,
		 				assignment: new_assignment
		 			)
		 		else
		 			Question.create(
		 				question_type: question.question_type,
		 				question: question.question,
		 				point_value: question.point_value,
		 				assignment: new_assignment
		 			)
		 		end
	 		end

 			render json: {assignment: {details: new_assignment, creator: new_assignment.creator}, success: "Assignment successfully copied"}
 		else
 			render json: {failure: "Assignment copy failed!"}
 		end

 	end

 	def delete_assignment
 		assignment = Assignment.find(params[:id])
 		assignment.questions.destroy_all
 		assignment.issued_assignments.destroy_all
 		assignment.destroy

 		render json: {success: "Successfully deleted assignment"}
 	end 	

 	def delete_assigned_assignment
 		issued_assignment = IssuedAssignment.find(params[:id])

 		issued_assignment.destroy

 		render json: {success: "Successfully deleted assigned assignment"}
 	end

 end
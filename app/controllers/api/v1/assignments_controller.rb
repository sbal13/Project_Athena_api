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
 			new_questions = params[:questions].map do |question|
	 			new_question = Question.create(
	 				question: question[:question],
	 				answer: question[:answer],
	 				choices: question[:choices],
	 				point_value: question[:points],
	 				assignment: assignment
	 			)
	 		end

	 		assignment.update(total_points: assignment.questions.pluck(:point_value).reduce(:+))

 			render json: {assignment: {details: assignment, creator: assignment.teacher, questions: new_questions}, success: "Test successfully saved"}
 		else
 			render json: {failure: "Oops! Something went wrong with saving your test!"}
 		end
 	end

 	def index
 		assignments = Assignment.all
 		assignments = assignments.map do |assignment|
 			questions = assignment.questions
 			{details: assignment, creator: assignment.teacher, questions: questions}
 		end
 		render json: {assignments: assignments, success: "Successfully obtained assignments"}
 	end


 	def show
 		assignment = Assignment.find(params[:id])

 		if assignment
 			render json: {assignment: {details: assignment, questions: assignment.questions}, success: "Successfully found #{assignment.id}"}
 		else
 			render json: {failure: "Oops! Didn't find that assignment!"}
 		end
 	end

 	def submit
 		
 		issued_assignment = IssuedAssignment.find_by(assignment_id: params[:id], student_id: current_user.id)
 		assignment = Assignment.find(params[:id])

 		total_score = 0

 		assignment.questions.each_with_index do |question, index|
 			total_score += question.point_value if question.answer == params[:answers][index]
 		end


 		if assignment.assignment_type == "multiple choice"
 			status = "Graded"
 		else 
 			status = "Submitted"
 		end



 		if issued_assignment.update(final_score: total_score, status: status)
 			render json: {assignment: issued_assignment, success: "Successfully submitted"}
 		else
 			render json: {failure: "Submission failed!"}
 		end

 	end

 	def teacher_assignments
 		teacher = User.find(params[:id])

 		assignments = teacher.assignments.map do |assignment|
 			{details: assignment}
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
 		assignment = Assignment.find(params[:assignment_id])
 		student = User.find(params[:student_id])

 		if assignment && student 
 			
 			if !!student.issued_assignments.find_by(assignment: assignment)
 				render json: {failure: "You've already assigned #{assignment.title} to #{student.username}"}
 			else

		 		issued_assignment = IssuedAssignment.new(student: student, assignment: assignment, status: "Pending", assigned_date: DateTime.now, due_date: params[:due_date])

		 		final = {issued_assignments: {assignment_details: assignment, details: issued_assignment}}

		 		if issued_assignment.save
		 			render json: {assignment: final, success: "Assignment Successful!"}
		 		else
		 			render json: {failure: "Failed to save assignment!"}
		 		end
		 	end
	 	else 
	 		render json: {failure: "Failed to locate student or assignment!"}
	 	end

 	end

 end
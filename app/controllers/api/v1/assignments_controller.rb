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
 				teacher: current_user
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
 		
 		assignment = Assignment.find(params[:id])

 		total_score = 0

 		assignment.questions.each_with_index do |question, index|
 			total_score += question.point_value if question.answer == params[:answers][index]
 		end

 		completedAssignment = IssuedAssignment.new(assignment: assignment, student: current_user, final_score: total_score)

 		if completedAssignment.save 
 			render json: {assignment: completedAssignment, success: "Successfully submitted"}
 		else
 			render json: {failure: "Submission failed!"}
 		end

 	end
 end
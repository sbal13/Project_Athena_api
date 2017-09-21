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
 			)

 		params[:questions].each do |question|
 			new_question = Question.create(
 				question: question[:question],
 				answer: question[:answer],
 				choices: question[:choices],
 				point_value: question[:points]
 			)
 			assignment.questions << new_question

 		end

 		if assignment.save 
 			render json: {assignment: assignment, success: "Test successfully saved"}
 		else
 			render json: {failure: "Oops! Something went wrong with saving your test!"}
 		end
 	end
 end
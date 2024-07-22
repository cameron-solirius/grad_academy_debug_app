# StepsController manages the flow of steps in a quiz application,
# including viewing, editing, updating, and finalizing quiz forms.
class StepsController < ApplicationController
  include Authentication
  include QuizConstantsHelper
  include QuizResultsHelper
  include StepsConcern
  include StepsHelper
  include ScoreboardHelper
  include QuizFormHandler

  before_action :authenticate_user!
  before_action :validate_step, only: %i[show edit update]
  before_action :set_quiz_form, only: %i[show update]

  # GET /steps/:id
  # Displays the quiz form for the specified step.
  def show
    if params[:encoded_params].present?
      @quiz_form = QuizForm.new(decoded_params.permit(:current_step, quiz_results: []))
      @quiz_form.current_user_id = current_user.id
    else
      @quiz_form = QuizForm.new(current_step: params[:id].to_i, current_user_id: current_user.id)
    end

    restore_quiz_form_state
  end

  # GET /steps/:id/edit
  # Displays the quiz form for editing the specified step.
  def edit
    reset_user_completion_status
    build_quiz_form_with_answers
    restore_quiz_form_state
  end

  # PATCH /steps/:id
  # Updates the quiz form for the specified step.
  def update
    if @quiz_form.valid?
      @quiz_form.update_answers

      # Save current state in session
      session[:quiz_forms] ||= []
      session[:quiz_forms][@quiz_form.current_step - 1] = @quiz_form.attributes

      next_step 
    else
      render :show, status: :unprocessable_content
    end
  end

  # GET /check_your_answers
  # Displays the user's completed quiz for review.
  def check_your_answers
    @quiz_results = current_user.answers.last
    clean_and_complete_quiz
    render :check_your_answers
  end

  # GET /results
  # Displays the user's quiz results.
  def results
    clean_and_complete_quiz
    @quiz_results = current_user.answers.last
    @questions_per_page = QUESTIONS_PER_PAGE
    @score_percentage, @correct_answers, @total_questions = scoring_metrics(@quiz_results)
    @quiz_results.update(score: @score_percentage)

    clear_quiz_form_session_data # <- Clear the quiz form session data

    render :results
  end

  # GET /scoreboard
  # Displays the top scores of completed quizzes.
  # Allows download of scoreboard as CSV.
  def scoreboard
    @top_scores = Answer.where(completed: true).where.not(score: nil).includes(:user).order(score: :desc).limit(10)
    respond_to do |format|
      format.html
      format.csv { send_data generate_csvs(@top_scores), filename: 'top_scores.csv' }
    end
  end

  # GET /download/:id
  # Allows download of an individual quiz result as CSV.
  def download
    @answer = Answer.find(params[:id])
    respond_to do |format|
      format.csv { send_data generate_single_csv(@answer), filename: "quiz_#{@answer.id}_results.csv" }
    end
  end

  private

  # Sets the quiz form based on parameters or defaults.
  def set_quiz_form
    @quiz_form = if params[:quiz_form].present?
                   build_quiz_form_from_params(quiz_form_params)
                 elsif params[:encoded_params].present?
                   build_quiz_form_from_encoded_params
                 else
                   build_default_quiz_form
                 end
  end

  # Restores the state of the quiz form from session storage.
  def restore_quiz_form_state
    saved_state = session[:quiz_forms] && session[:quiz_forms][@quiz_form.current_step - 1]
    @quiz_form.assign_attributes(saved_state) if saved_state
  end

  # Validates that the requested step is within the expected range.
  def validate_step
    render file: Rails.public_path.join('404.html'), status: :not_found unless (1..3).cover?(params[:id].to_i)
  end

  # Marks the current user's quiz as completed and cleans up unfinished attempts.
  def clean_and_complete_quiz
    current_user.answers.last.update(completed: true)
    current_user.answers.where(completed: false).destroy_all
  end
end

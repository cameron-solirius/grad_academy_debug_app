# QuizFormHandler module provides methods for handling quiz form operations.
module QuizFormHandler
  extend ActiveSupport::Concern

  # Advances the quiz form to the next step and redirects accordingly.
  def next_step
    if @quiz_form.current_step < @quiz_form.total_steps
      @quiz_form.current_step += 1
      encoded_params = UrlParamsEncoder.encode(answer: @quiz_form.answer, current_step: @quiz_form.current_step)
      redirect_to step_path(@quiz_form.current_step, encoded_params:, locale: I18n.locale)
    else
      redirect_to check_your_answers_steps_path(encoded_params:, locale: I18n.locale)
    end
  end

  # Resets the completion status of the last answer submitted by the current user.
  def reset_user_completion_status
    return if current_user.answers.blank?

    current_user.answers.last.update(completed: false)
  end

  # Builds a new quiz form instance with answers based on the provided params.
  def build_quiz_form_with_answers
    @quiz_form = QuizForm.new(current_step: params[:id].to_i, current_user_id: current_user.id)
    populate_quiz_form_with_answers
  end

  # Populates the quiz form with answers for a specific question based on params.
  def populate_quiz_form_with_answers
    question_index = :"question_#{params[:id]}"
    answers = params.dig(:answer, question_index) || []

    answers.each_with_index do |answer, i|
      set_answer_for_question(i, answer)
    end
  end

  # Sets the answer for a specific question index in the quiz form.
  def set_answer_for_question(index, answer)
    answer_key = "answer_#{index + 1}"
    @quiz_form.send(:"#{answer_key}=", answer)
  end

  # Clears the session data related to quiz forms.
  def clear_quiz_form_session_data
    session[:quiz_forms] = nil
  end
end

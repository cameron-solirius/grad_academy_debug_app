# QuizResultsHelper provides helper methods for managing and displaying quiz results.
#
module QuizResultsHelper
  include QuizConstantsHelper

  # Calculates scoring metrics based on quiz results.
  #
  # Parameters:
  # - quiz_results: Object containing quiz results data.
  #
  # Returns:
  # - Array containing score percentage, number of correct answers, and total questions.
  #
  def scoring_metrics(quiz_results)
    correct_answers = total_correct_answers(quiz_results)
    score_percentage = score_percentage(quiz_results) || 0
    [score_percentage, correct_answers, TOTAL_QUESTIONS]
  end

  # Counts the total number of correct answers in the quiz results.
  #
  # Parameters:
  # - quiz_results: Object containing quiz results data.
  #
  # Returns:
  # - Integer representing the total number of correct answers.
  #
  def total_correct_answers(quiz_results)
    total_correct = 0
    quiz_results.answer.each_with_index do |answers, page_index|
      answers.each_with_index do |answer, question_index|
        correct_answer = fetch_correct_answer(page_index, question_index)
        total_correct += 1 if check_answer(correct_answer, answer)
      end
    end
    total_correct
  end

  # Calculates the score percentage based on the number of correct answers.
  #
  # Parameters:
  # - quiz_results: Object containing quiz results data.
  #
  # Returns:
  # - Float representing the score percentage rounded to two decimal places.
  #
  def score_percentage(quiz_results)
    return 0 if TOTAL_QUESTIONS.zero?

    (total_correct_answers(quiz_results).to_f / TOTAL_QUESTIONS * 100)
  end

  # Checks if a user's answer matches the correct answer.
  #
  # Parameters:
  # - correct_answer: String representing the correct answer.
  # - user_answer: String representing the user's answer.
  #
  # Returns:
  # - Boolean indicating whether the user's answer is correct.
  #
  def check_answer(correct_answer, user_answer)
    return false if correct_answer == 'N/A' || user_answer == 'N/A'
  
    correct_answer.strip.downcase 
  end

  # Generates a table row displaying question, correct answer, user's answer, and result (Correct/Incorrect).
  #
  # Parameters:
  # - page_index: Index of the quiz page.
  # - question_index: Index of the question within the quiz page.
  # - answers: 2D array containing answers data.
  #
  # Returns:
  # - HTML table row (`<tr>`) containing table data (`<td>`) for each column.
  #
  def generate_table_row(page_index, question_index, answers)
    correct_answer = fetch_correct_answer(page_index, question_index)
    question = fetch_question(page_index, question_index)
    user_answer = fetch_user_answer(answers, question_index)
    result = evaluate_result(correct_answer, user_answer)

    content_tag(:tr) do
      generate_table_data(question, correct_answer, user_answer, result)
    end
  end

  private

  # Retrieves the correct answer for a specific question in a quiz page.
  #
  # Parameters:
  # - page_index: Index of the quiz page.
  # - question_index: Index of the question within the quiz page.
  #
  # Returns:
  # - String containing the correct answer or "N/A" if not found.
  #
  def fetch_correct_answer(page_index, question_index)
    I18n.t("quiz_form.question_page_#{page_index + 1}.question_#{question_index + 1}.correct_answer", default: 'N/A')
  end

  # Retrieves the question text for a specific question in a quiz page.
  #
  # Parameters:
  # - page_index: Index of the quiz page.
  # - question_index: Index of the question within the quiz page.
  #
  # Returns:
  # - String containing the question text or "N/A" if not found.
  #
  def fetch_question(page_index, question_index)
    I18n.t("quiz_form.question_page_#{page_index + 1}.question_#{question_index + 1}.question", default: 'N/A')
  end

  # Retrieves the user's answer for a specific question.
  #
  # Parameters:
  # - answers: 2D array containing answers data.
  # - question_index: Index of the question within the quiz page.
  #
  # Returns:
  # - String containing the user's answer or "N/A" if not found.
  #
  def fetch_user_answer(answers, question_index)
    answers[1][question_index]
  rescue StandardError
    'N/A'
  end

  # Evaluates the result of a user's answer against the correct answer.
  #
  # Parameters:
  # - correct_answer: String representing the correct answer.
  # - user_answer: String representing the user's answer.
  #
  # Returns:
  # - String indicating whether the user's answer was "Correct" or "Incorrect".
  #
  def evaluate_result(correct_answer, user_answer)
    if correct_answer.strip.downcase == user_answer.strip.downcase
      'Correct'
      else
        'Incorrect'
      end
  end

  # Generates table data (`<td>`) for question, correct answer, user's answer, and result.
  #
  # Parameters:
  # - question: String representing the question text.
  # - correct_answer: String representing the correct answer.
  # - user_answer: String representing the user's answer.
  # - result: String indicating the result ("Correct" or "Incorrect").
  #
  # Returns:
  # - HTML table data (`<td>`) containing formatted content for each column.
  #
  def generate_table_data(question, correct_answer, user_answer, result)
    content_tag(:td, question) +
      content_tag(:td, correct_answer.titleize) +
      content_tag(:td, user_answer) +
      content_tag(:td, result)
  end
end

# ScoreboardHelper provides helper methods for generating CSV files related to quiz scores and answers.
#
# Public Methods:
# - generate_csvs(scores): Generates a CSV file listing scores, usernames, dates, and percentages.
# - generate_single_csv(score): Generates a detailed CSV file for a single quiz score, including quiz details,
#   usernames, dates, and answers given versus correct answers.
#
module ScoreboardHelper
  require 'csv'

  # Generates a CSV file listing scores, usernames, dates, and percentages.
  #
  # Parameters:
  # - scores: An array of scores to include in the CSV.
  #
  # Returns:
  # - A CSV string containing the scores information.
  def generate_csvs(scores)
    return CSV.generate { |csv| csv << %w[Quiz Username Date Score] } if scores.empty?

    CSV.generate(encoding: 'UTF-8') do |csv|
      csv << %w[Quiz Username Date Score]
      scores.each do |score|
        user = score.user
        csv << [
          score.id, user.username, score.date_attempted.strftime('%B %d, %Y'), "#{score.score}%"
        ]
      end
    end
  end

  # Generates a detailed CSV file for a single quiz score, including quiz details,
  # usernames, dates, and answers given versus correct answers.
  #
  # Parameters:
  # - score: The score object for which to generate the CSV.
  #
  # Returns:
  # - A CSV string containing the detailed score information.
  def generate_single_csv(score)
    CSV.generate do |csv|
      csv << %w[Quiz_ID Username Date_Attempted Overall_Score Question Given_Answer Correct_Answer]

      score.answer.each do |page, answers|
        answers.each_with_index do |given_answer, index|
          question_data = fetch_question_data(load_questions, page, index)
          next unless question_data

          csv << build_csv_row(score, question_data, given_answer)
        end
      end
    end
  end

  private

  # Loads quiz questions from internationalization files.
  #
  # Returns:
  # - Hash containing quiz questions.
  def load_questions
    I18n.t('quiz_form')
  end

  # Retrieves question data based on page and index from loaded questions.
  #
  # Parameters:
  # - questions: Hash containing quiz questions.
  # - page: String representing the quiz page.
  # - index: Integer representing the index of the question on the page.
  #
  # Returns:
  # - Hash containing question data.
  def fetch_question_data(questions, page, index)
    page_number = page.split('_').last
    question_key = :"question_page_#{page_number}"
    questions[question_key][:"question_#{index + 1}"]
  end

  # Builds a CSV row for the given score, question data, and given answer.
  #
  # Parameters:
  # - score: The score object for which to build the CSV row.
  # - question_data: Hash containing data of the question.
  # - given_answer: String representing the answer given by the user.
  #
  # Returns:
  # - Array representing a CSV row.
  def build_csv_row(score, question_data, given_answer)
    [
      score.id,
      score.user.username,
      score.date_attempted.strftime('%B %d, %Y'),
      "#{score.score}%",
      question_data[:question],
      given_answer,
      question_data[:correct_answer]
    ]
  end
end

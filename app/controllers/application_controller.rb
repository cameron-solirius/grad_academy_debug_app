# ApplicationController is the base controller for all controllers in the application.
# It includes Authentication module and provides common functionality like clearing quiz session data
# based on conditions.
class ApplicationController < ActionController::Base
  include Authentication

  before_action :clear_quiz_session_data, unless: :on_quiz_page?
  before_action :set_locale

  if controller_name == 'home'
    @title_name = 'Quizlet'
  else
    @title_name = 'Quizlet -'
  end

  # Sets the locale for the application based on user's preferred language or browser settings.
  def set_locale
    if current_user&.language.present?
      # Use user's preferred language if available
      I18n.locale = current_user.language.to_sym
    else
      # Fall back to browser's preferred language if user's language not set
      browser_locale = extract_locale_from_accept_language_header
      I18n.locale = I18n.available_locales.include?(browser_locale&.to_sym) ? browser_locale : I18n.default_locale
    end
  end

  # catch all route for not found urls - all controllers will inherit this
  def render_404
    respond_to do |format|
      format.html { render file: Rails.public_path.join('404.html').to_s, layout: 'application', status: :not_found }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.any  { head :not_found }
    end
  end

  private

  # Extracts locale from the Accept-Language header sent by the browser.
  #
  # Returns:
  # - Two-letter language code extracted from the Accept-Language header.
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
  end

  # Clears quiz session data if the current action is not related to the quiz.
  def clear_quiz_session_data
    session[:quiz_forms] = nil
  end

  # Checks if the current action is related to the quiz.
  #
  # Returns:
  # - Boolean indicating if the current action is a quiz action.
  def on_quiz_page?
    quiz_actions = StepsController.action_methods
    controller_name == 'steps' && quiz_actions.include?(action_name)
  end
end

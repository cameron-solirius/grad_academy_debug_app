# ApplicationHelper provides helper methods for the QuizApp application.
#
module ApplicationHelper
  # Generates a full title for the QuizApp pages.
  #
  # Parameters:
  # - page_title: Optional string representing the title of the current page.
  #
  # Returns:
  # - String containing the full title, combining the base title "QuizApp" with the provided page title.
  #
  def full_title(page_title = '')
    base_title = 'QuizApp'
    if page_title.empty?
      base_title+' '+page_title
    else
      base_title+' - '+page_title
    end
  end

  # Generates html for the Navbar logo
  def logo_html
    content_tag('h3', class: 'text-white fw-normal m-0') do
      image_tag('logo-white.svg') + 'QUIZAPP'.html_safe
    end
  end
end

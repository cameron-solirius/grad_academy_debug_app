# UsersController manages user-related actions such as registration, editing profile, and updating user information.
class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update]
  before_action :redirect_if_authenticated, only: %i[create new]

  # GET /users/new
  # Displays the user registration form.
  def new
    @user = User.new
  end

  # GET /users/edit
  # Displays the user profile edit form.
  def edit
    # Memoized variable for current_user's top score.
    @edit ||= Answer.
              where(completed: true).
              where(user: current_user).
              where.not(score: nil).
              order(score: :desc).
              first&.
              score || I18n.t('users.no_score_available')
  end

  # POST /users
  # Creates a new user based on the submitted parameters.
  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      session[:current_user_id] = @user.id
      redirect_to welcome_path(locale: I18n.locale), notice: I18n.t('users.signed_up')
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH /users
  # Updates the current user's profile based on the submitted parameters.
  def update
    if current_user.update(user_update_params)
      redirect_to edit_user_path(locale: current_user.language), notice: I18n.t('users.updated')
    else
      render :edit, status: :unprocessable_content, locale: I18n.locale
    end
  end

  private

  # Strong parameters for user creation. User params are defined here
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  # Strong parameters for user update.
  def user_update_params
    params.require(:user).permit(:username, :language)
  end
end

class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    # The same answer whether the address has an account or not, so the page tells nobody which ones do.
    redirect_to new_session_path, notice: "If that email address has an account, a link to choose a new password is on its way."
  end

  def edit
  end

  # A refused password ends as every refused write: 422, the form again, the messages next to the fields.
  def update
    @user.assign_attributes(params.expect(user: [ :password, :password_confirmation ]))

    if @user.save(context: :password_reset)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Your password has been changed. Sign in with the new one."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end

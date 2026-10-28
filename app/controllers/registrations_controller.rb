class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      # After the response, from a job: the request doesn't wait for the email.
      WelcomeMailer.welcome(@user).deliver_later
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Wheelhouse. Your account #{@user.email_address} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # No role and no member of the staff: an account made here gets the default role, and the owner
  # changes it from the seed or the console.
  def registration_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end

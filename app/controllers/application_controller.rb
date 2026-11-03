class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Every action asks its policy, and every index is built from a policy scope. An action that forgets
  # raises Pundit's error instead of answering, so a new controller is covered without a line written in
  # it. The public actions that ask no policy skip this themselves and are listed in docs/decisions.md.
  # (`if:` rather than `only: :index`, because a controller with no index would otherwise refuse to load.)
  after_action :verify_authorized
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  # The policies receive the account of the current session; nil for a visitor. The session is resumed
  # first, because a public page (the price list) skips the sign-in check that would have loaded it.
  def pundit_user
    resume_session
    Current.user
  end

  # A refused request ends here, before anything is written: a 403 page in the application's layout.
  # Also after a form's submission, which Turbo draws in place of the form because of the status.
  def forbidden
    render "errors/forbidden", status: :forbidden
  end
end

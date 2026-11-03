# frozen_string_literal: true

# The workshop's own pages (Home, Visit, About). They have no model, so they are asked with a symbol:
# authorize :page, :home?. Every account reads them; a visitor is sent to sign in before getting here.
class PagePolicy < ApplicationPolicy
  def home?
    account?
  end

  def visiting?
    account?
  end

  def about?
    account?
  end
end

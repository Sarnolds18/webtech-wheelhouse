# frozen_string_literal: true

# The staff. Every account reads who works at the workshop; only the owner adds, renames or removes them.
class MechanicPolicy < ApplicationPolicy
  def index?
    account?
  end

  def show?
    account?
  end

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def permitted_attributes
    [ :name ]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.all : scope.none
    end
  end
end

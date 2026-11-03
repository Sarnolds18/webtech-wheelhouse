# frozen_string_literal: true

# The wall list. Anyone reads it, a visitor included; only the owner changes it.
class ServicePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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
    [ :name, :price, :category ]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

# frozen_string_literal: true

# Customers are the counter's work: the counter takes them in, edits and reads them. Only the owner
# deletes one. A mechanic works on the bike, not with the customer, and has no access.
class CustomerPolicy < ApplicationPolicy
  def index?
    owner? || counter?
  end

  def show?
    owner? || counter?
  end

  def create?
    owner? || counter?
  end

  def update?
    owner? || counter?
  end

  def destroy?
    owner?
  end

  def permitted_attributes
    [ :name, :phone ]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      owner? || counter? ? scope.all : scope.none
    end
  end
end

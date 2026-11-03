# frozen_string_literal: true

# Bikes follow their customers: the counter takes them in, edits and reads them, only the owner deletes
# one, and a mechanic has no access (they see the bike's serial number on their own repairs).
class BikePolicy < ApplicationPolicy
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
    [ :serial_number, :bike_model_id, :customer_id ]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      owner? || counter? ? scope.all : scope.none
    end
  end
end

# frozen_string_literal: true

# The base of every policy: it refuses everything. A policy allows an action only by writing the method
# for it, so an action whose method was never written is refused, never allowed.
#
# `user` is the account of the current session (nil for a visitor), handed in by the controller. No policy
# reads the session, the params or Current on its own. Roles are asked with the enum's methods
# (role_owner?, role_counter?, role_mechanic?), never compared with a string.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # The attributes this person may write: none unless the policy says which.
  def permitted_attributes
    []
  end

  # Whether one field of the form is in the person's list, so the form draws only those fields. A nested
  # or array attribute is a hash in the list ({ photos: [] }); its key is the field.
  def permitted_attribute?(name)
    permitted_attributes.any? { |attribute| attribute == name || (attribute.is_a?(Hash) && attribute.key?(name)) }
  end

  private

  def account?
    user.present?
  end

  def owner?
    user&.role_owner? || false
  end

  def counter?
    user&.role_counter? || false
  end

  def mechanic?
    user&.role_mechanic? || false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Like the policy, the scope refuses by default: a scope that was never written returns nothing.
    def resolve
      scope.none
    end

    private

    attr_reader :user, :scope

    def owner?
      user&.role_owner? || false
    end

    def counter?
      user&.role_counter? || false
    end

    def mechanic?
      user&.role_mechanic? || false
    end
  end
end

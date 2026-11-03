# frozen_string_literal: true

# Repairs. The owner and the counter read every repair; a mechanic reads only their own, the ones whose
# mechanic is the member of the staff joined to their account. The scope and show? give the same answer.
#
# A repair is handed back once it reaches the last state of its lifecycle (collected). After that only
# the owner edits it.
class RepairPolicy < ApplicationPolicy
  def index?
    account?
  end

  def show?
    owner? || counter? || own?
  end

  # Taking a bike in is the counter's job; the owner can do it too.
  def create?
    owner? || counter?
  end

  def update?
    return true if owner?
    return false if record.collected?

    counter? || own?
  end

  def destroy?
    owner?
  end

  # Removing a stored intake photo, from Repairs::PhotosController. Whoever writes every field of the
  # repair may; a mechanic only adds photos.
  def destroy_photo?
    update? && (owner? || counter?)
  end

  # The fields of the repair's form. The owner and the counter write all of them; a mechanic writes the
  # state, the diagnosis and new intake photos of their repairs, and nothing else. The account that took
  # the repair in is never a field: the controller reads it from the session.
  def permitted_attributes
    if owner? || counter?
      [ :bike_id, :mechanic_id, :state, :received_at, :promised_on,
        :quoted_at, :quoted_amount, :quote_response, :responded_at,
        :finished_at, :collected_at, :diagnosis,
        { repair_services_attributes: [ [ :id, :service_id, :charged_price, :_destroy ] ] },
        { photos: [] } ]
    elsif mechanic?
      [ :state, :diagnosis, { photos: [] } ]
    else
      []
    end
  end

  private

  # A repair is the mechanic's own when it is assigned to their member of the staff. An account that
  # belongs to no one on the staff owns no repair.
  def own?
    mechanic? && user.mechanic_id.present? && record.mechanic_id == user.mechanic_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if owner? || counter?
        scope.all
      elsif mechanic? && user.mechanic_id
        scope.where(mechanic_id: user.mechanic_id)
      else
        scope.none
      end
    end
  end
end

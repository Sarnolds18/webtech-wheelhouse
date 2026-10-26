class Mechanic < ApplicationRecord
  has_many :repairs, -> { newest_first }, dependent: :nullify
  # A member of the staff who signs in can't be deleted out from under their account.
  has_one :user, dependent: :restrict_with_error

  scope :by_name, -> { order(:name) }

  validates :name, presence: true
end

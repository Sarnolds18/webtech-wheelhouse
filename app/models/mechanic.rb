class Mechanic < ApplicationRecord
  has_many :repairs, dependent: :nullify

  validates :name, presence: true
end

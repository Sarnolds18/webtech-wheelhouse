class Mechanic < ApplicationRecord
  has_many :repairs, dependent: :nullify
end

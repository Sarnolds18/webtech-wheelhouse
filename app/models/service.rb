class Service < ApplicationRecord
  has_many :repair_services
  has_many :repairs, through: :repair_services
end

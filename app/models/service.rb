class Service < ApplicationRecord
  has_many :repair_services, dependent: :restrict_with_error
  has_many :repairs, through: :repair_services
end

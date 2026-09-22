class Bike < ApplicationRecord
  belongs_to :bike_model
  belongs_to :customer
  has_many :repairs, dependent: :restrict_with_error
end

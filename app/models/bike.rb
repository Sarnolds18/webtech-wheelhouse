class Bike < ApplicationRecord
  belongs_to :bike_model
  belongs_to :customer
  has_many :repairs, -> { newest_first }, dependent: :restrict_with_error

  scope :by_serial_number, -> { order(:serial_number) }

  validates :serial_number, presence: true, uniqueness: true
end

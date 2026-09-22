class Bike < ApplicationRecord
  belongs_to :bike_model
  belongs_to :customer
  has_many :repairs, -> { newest_first }, dependent: :restrict_with_error

  scope :by_serial_number, -> { order(:serial_number) }

  before_validation { self.serial_number = serial_number.strip.upcase if serial_number.present? }

  validates :serial_number, presence: true, uniqueness: true
end

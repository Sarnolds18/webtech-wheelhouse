class Customer < ApplicationRecord
  has_many :bikes, -> { by_serial_number }, dependent: :restrict_with_error
  has_many :repairs, -> { newest_first }, dependent: :restrict_with_error
  has_many :repairs_via_bikes, through: :bikes, source: :repairs

  scope :by_name, -> { order(:name) }

  validates :name, presence: true
  validates :phone, presence: true
end

class Service < ApplicationRecord
  has_many :repair_services, dependent: :restrict_with_error
  has_many :repairs, through: :repair_services

  scope :by_category_and_name, -> { order(:category, :name) }

  before_validation { self.name = name.strip if name.present? }

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end

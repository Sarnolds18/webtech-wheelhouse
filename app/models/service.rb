class Service < ApplicationRecord
  has_many :repair_services, dependent: :restrict_with_error
  has_many :repairs, through: :repair_services

  scope :by_category_and_name, -> { order(:category, :name) }

  # An empty category from the form is saved as NULL, so the service lists under "Other services".
  before_validation do
    self.name = name.strip if name.present?
    self.category = category.to_s.strip.presence
  end

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end

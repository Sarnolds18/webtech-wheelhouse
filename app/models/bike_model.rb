class BikeModel < ApplicationRecord
  has_many :bikes, dependent: :restrict_with_error

  scope :by_brand_and_name, -> { order(:brand, :name) }

  validates :brand, presence: true
  validates :name, presence: true

  def brand_and_name
    "#{brand} #{name}"
  end
end

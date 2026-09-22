class BikeModel < ApplicationRecord
  has_many :bikes, dependent: :restrict_with_error

  validates :brand, presence: true
  validates :name, presence: true
end

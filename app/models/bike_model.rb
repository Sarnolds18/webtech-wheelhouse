class BikeModel < ApplicationRecord
  has_many :bikes, dependent: :restrict_with_error
end

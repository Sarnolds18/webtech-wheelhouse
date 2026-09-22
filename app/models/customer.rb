class Customer < ApplicationRecord
  has_many :bikes, dependent: :restrict_with_error
  has_many :repairs, dependent: :restrict_with_error
  has_many :repairs_via_bikes, through: :bikes, source: :repairs
end

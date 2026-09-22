class Customer < ApplicationRecord
  has_many :bikes
  has_many :repairs
  has_many :repairs_via_bikes, through: :bikes, source: :repairs
end

class Invoice < ApplicationRecord
  belongs_to :repair

  validates :repair_id, uniqueness: true
  validates :number, presence: true, uniqueness: true
  validates :issued_at, presence: true
end

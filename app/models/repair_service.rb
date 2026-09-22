class RepairService < ApplicationRecord
  belongs_to :repair
  belongs_to :service

  scope :in_order_added, -> { order(:created_at) }

  validates :charged_price, presence: true, numericality: { greater_than: 0 }
end

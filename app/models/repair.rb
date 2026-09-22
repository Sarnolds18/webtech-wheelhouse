class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :mechanic, optional: true

  has_many :repair_services, -> { in_order_added }, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :services, through: :repair_services

  enum :state, {
    received: "received",
    diagnosed: "diagnosed",
    quoted: "quoted",
    approved: "approved",
    declined: "declined",
    in_progress: "in_progress",
    finished: "finished",
    collected: "collected"
  }

  scope :open, -> { where.not(state: :collected) }
  scope :overdue, -> { open.where("promised_on < ?", Date.current) }
  scope :newest_first, -> { order(received_at: :desc) }

  validates :state, presence: true
  validates :received_at, presence: true
  validates :promised_on, presence: true
  validates :quoted_amount, numericality: { greater_than: 0 }, allow_nil: true

  validate :handback_and_promised_day_not_before_received
  validate :answer_recorded_once_customer_has_answered

  def overdue?
    promised_on < Date.current && !collected?
  end

  def total
    repair_services.sum(:charged_price)
  end

  private

  def handback_and_promised_day_not_before_received
    return unless received_at.present?

    if collected_at.present? && collected_at < received_at
      errors.add(:collected_at, "can't be before the day the repair was received")
    end

    if promised_on.present? && promised_on < received_at.to_date
      errors.add(:promised_on, "can't be before the day the repair was received")
    end
  end

  def answer_recorded_once_customer_has_answered
    if collected_at.present? && !collected?
      errors.add(:collected_at, "can't be set unless the repair has been collected")
    end

    if (approved? || declined?) && quote_response.blank?
      errors.add(:quote_response, "must be recorded once the customer has answered")
    end
  end
end

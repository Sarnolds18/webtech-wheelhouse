class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :mechanic, optional: true

  has_many :repair_services, -> { in_order_added }, dependent: :destroy, index_errors: true
  has_many :invoices, dependent: :destroy
  has_many :services, through: :repair_services

  # Photos taken when the bike came in. Only the image types the shop's phones produce are
  # accepted, up to a size limit; both are checked on the photos being added, not on old ones.
  PHOTO_TYPES = %w[ image/jpeg image/png image/webp ].freeze
  PHOTO_MAX_SIZE = 10.megabytes

  # Lists show every photo as a square of this side, cropped to fill it, so they all measure the same
  # whatever the proportions of the original; the repair's page shows a larger copy that keeps them.
  THUMB_SIZE = 80

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_fill: [ THUMB_SIZE, THUMB_SIZE ]
    attachable.variant :large, resize_to_limit: [ 1000, 1000 ]
  end

  # The repair's form writes its lines. A new line whose service is left empty is one of the spare
  # lines the form offers, so it is skipped; an existing line is taken off with _destroy.
  accepts_nested_attributes_for :repair_services, allow_destroy: true,
                                                  reject_if: ->(line) { line["id"].blank? && line["service_id"].blank? }

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

  # The customer's answer to the quote. Its values are spelled like two states, so the prefix keeps
  # its methods apart from the state's: quote_approved? vs approved?.
  enum :quote_response, { approved: "approved", declined: "declined" }, prefix: :quote

  scope :open, -> { where.not(state: :collected) }
  scope :overdue, -> { open.where("promised_on < ?", Date.current) }
  scope :newest_first, -> { order(received_at: :desc) }

  # The customer on a repair is whoever brought the bike in on that visit (docs/decisions.md). It is
  # taken from the bike when the repair is created or its bike is corrected, and left alone otherwise,
  # so an old repair still names the right person after the bike is sold.
  before_validation :take_customer_from_bike, if: :will_save_change_to_bike_id?

  validates :state, presence: true
  validates :received_at, presence: true
  validates :promised_on, presence: true
  validates :quoted_amount, numericality: { greater_than: 0 }, allow_nil: true

  validate :handback_and_promised_day_not_before_received
  validate :answer_recorded_once_customer_has_answered
  validate :photos_are_images_within_size_limit

  # Errors on a line are keyed "repair_services[1].charged_price"; this names them the way the form
  # does, as "Line 2 charged price", so the counter knows which line to fix.
  def self.human_attribute_name(attribute, options = {})
    line = attribute.to_s.match(/\Arepair_services\[(\d+)\]\.(.+)\z/)
    return super unless line

    "Line #{line[1].to_i + 1} #{RepairService.human_attribute_name(line[2]).downcase}"
  end

  def overdue?
    promised_on < Date.current && !collected?
  end

  def total
    repair_services.sum(:charged_price)
  end

  private

  def take_customer_from_bike
    self.customer_id = bike.customer_id if bike
  end

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

  def photos_are_images_within_size_limit
    photos.attachments.select(&:new_record?).each do |photo|
      name = photo.blob.filename

      unless PHOTO_TYPES.include?(photo.blob.content_type)
        errors.add(:photos, "\"#{name}\" is not a JPEG, PNG or WebP image")
      end

      if photo.blob.byte_size > PHOTO_MAX_SIZE
        size = (photo.blob.byte_size.to_f / 1.megabyte).round(1)
        errors.add(:photos, "\"#{name}\" is #{size} MB; the limit is #{PHOTO_MAX_SIZE / 1.megabyte} MB")
      end
    end
  end
end

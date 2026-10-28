class User < ApplicationRecord
  PASSWORD_MINIMUM_LENGTH = 10

  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :mechanic, optional: true
  # An account that took repairs in keeps that record: it can't be deleted while they point to it.
  has_many :repairs_taken_in, class_name: "Repair", foreign_key: :taken_in_by_id,
                              inverse_of: :taken_in_by, dependent: :restrict_with_error

  # The role is read from the seed or set from the console; no page chooses it. Its values would read
  # like the staff association (mechanic? vs mechanic), so the prefix keeps them apart: role_mechanic?.
  enum :role, { owner: "owner", mechanic: "mechanic", counter: "counter" }, prefix: true, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  # has_secure_password already requires a password on create; nil is an update that does not change it.
  validates :password, length: { minimum: PASSWORD_MINIMUM_LENGTH }, allow_nil: true
  # has_secure_password ignores a blank password on an update, so the reset form would "save" nothing.
  validates :password, presence: true, on: :password_reset
  validates :mechanic_id, uniqueness: { message: "already has an account" }, allow_nil: true

  # How the pages name the person behind the account: the staff member's name, or the email address
  # when the account belongs to no one on the staff.
  def display_name
    mechanic&.name || email_address
  end
end

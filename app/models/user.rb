class User < ApplicationRecord
  PASSWORD_MINIMUM_LENGTH = 10

  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :mechanic, optional: true

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
end

class User < ApplicationRecord
  MINIMUM_PASSWORD_LENGTH = 8

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: MINIMUM_PASSWORD_LENGTH }, allow_nil: true

  # The token embeds the email address and confirmation state, so a link
  # stops working if the address changes or once it has been used.
  generates_token_for :email_confirmation, expires_in: 2.days do
    [ email_address, confirmed_at ]
  end

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current) unless confirmed?
  end
end

class Message < ApplicationRecord
  MAXIMUM_LENGTH = 1_000
  HISTORY_SIZE = 50

  belongs_to :user

  normalizes :body, with: ->(body) { body.strip }

  validates :body, presence: true, length: { maximum: MAXIMUM_LENGTH }

  after_create_commit -> { ChatChannel.broadcast_message(self) }

  # The most recent messages, oldest first, ready to display.
  def self.history(limit: HISTORY_SIZE)
    includes(:user).order(created_at: :desc, id: :desc).limit(limit).reverse
  end
end

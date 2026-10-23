# The numbers in a user's weekly email, counted up to a fixed point in time
# so every user's digest from the same run covers the same week.
class WeeklyDigest
  attr_reader :user, :as_of

  def initialize(user, as_of: Time.current)
    @user = user
    @as_of = as_of
  end

  # Every message in the room during the week before as_of. With a single
  # room, each message is both sent and received.
  def messages_last_week
    Message.where(created_at: (as_of - 1.week)..as_of).count
  end

  def last_message_at
    @last_message_at ||= user.messages.where(created_at: ..as_of).maximum(:created_at)
  end

  # When counting "received since" starts: the user's last message, or
  # when they joined if they've never posted.
  def since
    last_message_at || user.created_at
  end

  # Messages from other people since the user's last message.
  def messages_since_last_message
    Message.where.not(user: user).where(created_at: since..as_of).count
  end
end

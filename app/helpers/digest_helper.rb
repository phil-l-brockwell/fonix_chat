module DigestHelper
  # "600 messages have been exchanged in the last week."
  def messages_last_week_sentence(digest)
    count = digest.messages_last_week
    "#{pluralize(count, "message")} #{count == 1 ? "has" : "have"} been exchanged in the last week."
  end

  # "750 since your last message on the 1st of February."
  def messages_since_sentence(digest)
    reference = digest.last_message_at ? "your last message" : "you joined"
    "#{number_with_delimiter(digest.messages_since_last_message)} since #{reference} on the #{ordinal_date(digest.since)}."
  end

  # "1st of February", with the year added when it isn't the current one.
  def ordinal_date(time)
    date = time.to_date
    formatted = "#{date.day.ordinalize} of #{date.strftime("%B")}"
    date.year == Date.current.year ? formatted : "#{formatted} #{date.year}"
  end
end

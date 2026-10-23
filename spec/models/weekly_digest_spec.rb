require "rails_helper"

RSpec.describe WeeklyDigest do
  let(:as_of) { Time.zone.parse("2026-02-09 09:00") }
  let(:user) { create(:user, created_at: Time.zone.parse("2026-01-01 12:00")) }
  let(:other) { create(:user) }
  let(:digest) { described_class.new(user, as_of: as_of) }

  def message(from, at)
    create(:message, user: from, created_at: Time.zone.parse(at))
  end

  describe "#messages_last_week" do
    it "counts everyone's messages in the week before as_of, including the user's own" do
      message(other, "2026-02-02 08:59") # just over a week ago
      message(other, "2026-02-02 09:00")
      message(user, "2026-02-05 10:00")
      message(other, "2026-02-09 09:00")
      message(other, "2026-02-09 09:01") # after as_of

      expect(digest.messages_last_week).to eq(3)
    end
  end

  describe "#messages_since_last_message" do
    it "counts other people's messages since the user's last message" do
      message(user, "2026-01-20 10:00")
      message(other, "2026-01-25 10:00") # before the user's latest
      message(user, "2026-02-01 10:00")
      message(other, "2026-02-03 10:00")
      message(other, "2026-02-08 10:00")
      message(other, "2026-02-10 10:00") # after as_of

      expect(digest.last_message_at).to eq(Time.zone.parse("2026-02-01 10:00"))
      expect(digest.messages_since_last_message).to eq(2)
    end

    it "is unaffected by messages the user sends after as_of" do
      message(user, "2026-02-01 10:00")
      message(other, "2026-02-03 10:00")
      message(user, "2026-02-09 10:00") # after as_of

      expect(digest.since).to eq(Time.zone.parse("2026-02-01 10:00"))
      expect(digest.messages_since_last_message).to eq(1)
    end

    it "counts from when the user joined if they've never posted" do
      message(other, "2025-12-31 10:00") # before they joined
      message(other, "2026-01-15 10:00")

      expect(digest.last_message_at).to be_nil
      expect(digest.since).to eq(user.created_at)
      expect(digest.messages_since_last_message).to eq(1)
    end
  end
end

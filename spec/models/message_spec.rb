require "rails_helper"

describe Message, type: :model do
  describe "validations" do
    it "requires a body" do
      message = build(:message, body: "   ")

      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("can't be blank")
    end

    it "limits the body to #{Message::MAXIMUM_LENGTH} characters" do
      expect(build(:message, body: "a" * Message::MAXIMUM_LENGTH)).to be_valid
      expect(build(:message, body: "a" * (Message::MAXIMUM_LENGTH + 1))).not_to be_valid
    end

    it "strips surrounding whitespace" do
      expect(build(:message, body: "  hi  ").body).to eq("hi")
    end
  end

  describe ".history" do
    it "returns the most recent messages, oldest first" do
      old, middle, recent = 3.times.map { |i| create(:message, created_at: (3 - i).hours.ago) }

      expect(Message.history(limit: 2)).to eq([ middle, recent ])
      expect(Message.history).to eq([ old, middle, recent ])
    end
  end

  it "broadcasts itself to the chat room once saved" do
    expect { create(:message, body: "Broadcast me") }
      .to have_broadcasted_to(ChatChannel::STREAM).with(a_hash_including(html: a_string_including("Broadcast me")))
  end
end

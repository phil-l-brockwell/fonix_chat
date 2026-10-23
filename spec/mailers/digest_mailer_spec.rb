require "rails_helper"

describe DigestMailer, type: :mailer do
  let(:user) { create(:user, created_at: Time.zone.parse("2026-01-01 12:00")) }
  let(:other) { create(:user) }

  def message(from, at)
    create(:message, user: from, created_at: Time.zone.parse(at))
  end

  around { |example| travel_to(Time.zone.parse("2026-02-09 09:00")) { example.run } }

  describe "#weekly" do
    let(:mail) { described_class.weekly(user, as_of: Time.current) }
    let(:text) { mail.text_part.body.to_s }

    it "is addressed to the user" do
      expect(mail.to).to eq([ user.email_address ])
      expect(mail.subject).to eq("Your week on Fonix Chat")
    end

    context "when the user has posted" do
      before { message(user, "2026-02-03 10:00") }

      it "reports the week's total and the count since the user's last message" do
        message(other, "2026-01-31 10:00") # more than a week ago
        3.times { message(other, "2026-02-05 10:00") }

        [ mail.text_part, mail.html_part ].each do |part|
          expect(part.body.to_s).to include("4 messages have been exchanged in the last week.")
          expect(part.body.to_s).to include("3 since your last message on the 3rd of February.")
        end
      end

      it "uses the singular for one message" do
        expect(text).to include("1 message has been exchanged in the last week.")
      end
    end

    context "when the user has never posted" do
      it "counts from when they joined" do
        message(other, "2026-01-10 10:00")

        expect(text).to include("1 since you joined on the 1st of January.")
      end
    end

    context "when the date is from a previous year" do
      let(:user) { create(:user, created_at: Time.zone.parse("2025-11-22 12:00")) }

      it "adds the year" do
        expect(text).to include("0 since you joined on the 22nd of November 2025.")
      end
    end
  end
end

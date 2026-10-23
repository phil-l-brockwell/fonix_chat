require "rails_helper"

describe WeeklyDigestJob, type: :job do
  describe "#perform" do
    let!(:alice) { create(:user) }
    let!(:bob) { create(:user) }

    before { create(:user, :unconfirmed) }

    it "emails every confirmed user, counting up to the same moment" do
      freeze_time do
        expect { described_class.perform_now }
          .to have_enqueued_mail(DigestMailer, :weekly).with(alice, as_of: Time.current)
          .and have_enqueued_mail(DigestMailer, :weekly).with(bob, as_of: Time.current)
          .and have_enqueued_mail(DigestMailer, :weekly).exactly(2).times
      end
    end
  end

  describe "schedule" do
    let(:task) { YAML.load_file(Rails.root.join("config/recurring.yml")).dig("production", "weekly_digest") }

    it "runs at 9am every Monday, London time" do
      expect(task).to eq("class" => "WeeklyDigestJob", "schedule" => "every monday at 9am Europe/London")
    end
  end
end

require "rails_helper"

RSpec.describe WeeklyDigestJob, type: :job do
  it "emails every confirmed user, counting up to the same moment" do
    alice = create(:user)
    bob = create(:user)
    create(:user, :unconfirmed)

    freeze_time do
      expect { described_class.perform_now }
        .to have_enqueued_mail(DigestMailer, :weekly).with(alice, as_of: Time.current)
        .and have_enqueued_mail(DigestMailer, :weekly).with(bob, as_of: Time.current)
        .and have_enqueued_mail(DigestMailer, :weekly).exactly(2).times
    end
  end

  it "is scheduled for 9am every Monday, London time" do
    task = YAML.load_file(Rails.root.join("config/recurring.yml")).dig("production", "weekly_digest")

    expect(task).to eq("class" => "WeeklyDigestJob", "schedule" => "every monday at 9am Europe/London")
  end
end

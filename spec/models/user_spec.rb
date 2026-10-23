require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with an email address and a long enough password" do
      expect(build(:user)).to be_valid
    end

    it "requires a well-formed email address" do
      user = build(:user, email_address: "not-an-email")

      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("is invalid")
    end

    it "requires a unique email address, ignoring case and whitespace" do
      create(:user, email_address: "taken@example.com")
      user = build(:user, email_address: "  Taken@Example.com ")

      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("has already been taken")
    end

    it "requires a password of at least #{User::MINIMUM_PASSWORD_LENGTH} characters" do
      user = build(:user, password: "short")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end
  end

  describe "email confirmation token" do
    let(:user) { create(:user, :unconfirmed) }

    it "finds the user from a fresh token" do
      token = user.generate_token_for(:email_confirmation)

      expect(User.find_by_token_for(:email_confirmation, token)).to eq(user)
    end

    it "expires after 2 days" do
      token = user.generate_token_for(:email_confirmation)

      travel 2.days + 1.minute do
        expect(User.find_by_token_for(:email_confirmation, token)).to be_nil
      end
    end

    it "stops working once used" do
      token = user.generate_token_for(:email_confirmation)
      user.confirm!

      expect(User.find_by_token_for(:email_confirmation, token)).to be_nil
    end

    it "stops working if the email address changes" do
      token = user.generate_token_for(:email_confirmation)
      user.update!(email_address: "changed@example.com")

      expect(User.find_by_token_for(:email_confirmation, token)).to be_nil
    end
  end

  describe "#confirm!" do
    it "records when the user confirmed" do
      user = create(:user, :unconfirmed)

      freeze_time do
        user.confirm!
        expect(user.reload.confirmed_at).to eq(Time.current)
      end
    end

    it "keeps the original time if already confirmed" do
      user = create(:user, confirmed_at: 1.day.ago.round)

      expect { user.confirm! }.not_to change { user.reload.confirmed_at }
    end
  end
end

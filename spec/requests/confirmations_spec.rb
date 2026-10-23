require "rails_helper"

describe "Confirmations", type: :request do
  include ActiveJob::TestHelper

  let(:user) { create(:user, :unconfirmed) }

  describe "following the link" do
    let(:token) { user.generate_token_for(:email_confirmation) }

    it "confirms the account and signs the user in" do
      get confirmation_path(token)

      expect(response).to redirect_to(root_path)
      expect(user.reload).to be_confirmed

      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "rejects an invalid token" do
      get confirmation_path("bogus")

      expect(response).to redirect_to(new_confirmation_path)
      expect(user.reload).not_to be_confirmed
    end

    it "can't be used twice" do
      get confirmation_path(token)
      delete session_path

      get confirmation_path(token)

      expect(response).to redirect_to(new_confirmation_path)
    end
  end

  describe "resending the link" do
    it "emails a new link to an unconfirmed user" do
      expect { post confirmations_path, params: { email_address: user.email_address } }
        .to have_enqueued_mail(ConfirmationsMailer, :confirm).with(user)
    end

    it "sends nothing for a confirmed user or an unknown address" do
      confirmed = create(:user)

      expect { post confirmations_path, params: { email_address: confirmed.email_address } }.not_to have_enqueued_mail
      expect { post confirmations_path, params: { email_address: "nobody@example.com" } }.not_to have_enqueued_mail
    end
  end
end

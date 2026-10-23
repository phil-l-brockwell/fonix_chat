require "rails_helper"

RSpec.describe "Registrations", type: :request do
  include ActiveJob::TestHelper

  let(:params) do
    { user: { email_address: "new@example.com", password: "password123", password_confirmation: "password123" } }
  end

  it "creates an unconfirmed account and emails a confirmation link" do
    perform_enqueued_jobs do
      expect { post registration_path, params: params }.to change(User, :count).by(1)
    end

    expect(response).to redirect_to(new_session_path)
    expect(User.last).not_to be_confirmed

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([ "new@example.com" ])
    expect(mail.subject).to eq("Confirm your email address")
    expect(mail.text_part.body.to_s).to include("/confirmations/")
  end

  it "does not sign the new user in" do
    post registration_path, params: params
    get root_path

    expect(response).to redirect_to(new_session_path)
  end

  it "re-renders the form with errors for an invalid email address" do
    params[:user][:email_address] = "nope"

    expect { post registration_path, params: params }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Email address is invalid")
  end
end

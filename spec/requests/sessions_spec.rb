require "rails_helper"

RSpec.describe "Sessions", type: :request do
  it "signs in a confirmed user" do
    sign_in_as create(:user)

    expect(response).to redirect_to(root_url)
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "refuses an unconfirmed user and points them at the resend page" do
    user = create(:user, :unconfirmed)

    sign_in_as user

    expect(response).to redirect_to(new_confirmation_path(email_address: user.email_address))
    get root_path
    expect(response).to redirect_to(new_session_path)
  end

  it "refuses a wrong password" do
    sign_in_as create(:user), password: "wrong-password"

    expect(response).to redirect_to(new_session_path)
  end
end

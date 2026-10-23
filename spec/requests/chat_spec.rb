require "rails_helper"

describe "Chat", type: :request do
  it "requires signing in" do
    get root_path

    expect(response).to redirect_to(new_session_path)
  end

  it "shows the recent history" do
    create(:message, body: "Earlier message")
    sign_in_as create(:user)

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Earlier message")
  end
end

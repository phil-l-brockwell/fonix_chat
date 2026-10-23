require "rails_helper"

describe "Chat", type: :system do
  let(:alice) { create(:user, email_address: "alice@example.com") }
  let(:bob) { create(:user, email_address: "bob@example.com") }

  def sign_in(user)
    visit new_session_path
    fill_in "Enter your email address", with: user.email_address
    fill_in "Enter your password", with: "password123"
    click_on "Sign in"
    expect(page).to have_text("Connected")
  end

  it "delivers a message to everyone in the room without reloading" do
    using_session(:bob) { sign_in bob }

    using_session(:alice) do
      sign_in alice
      fill_in "Message", with: "Hi Bob!"
      click_on "Send"

      within("#messages") { expect(page).to have_text("Hi Bob!") }
      expect(page).to have_field("Message", with: "")
    end

    using_session(:bob) do
      within("#messages") do
        expect(page).to have_text("alice@example.com")
        expect(page).to have_text("Hi Bob!")
      end
    end
  end

  it "shows earlier messages when you arrive" do
    create(:message, user: bob, body: "Sent before Alice arrived")

    sign_in alice

    within("#messages") { expect(page).to have_text("Sent before Alice arrived") }
  end
end

require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
    subscribe
  end

  it "streams the chat room" do
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(ChatChannel::STREAM)
  end

  it "saves a spoken message from the current user and broadcasts it" do
    expect { perform :speak, body: "Hello over the socket" }
      .to change(user.messages, :count).by(1)
      .and have_broadcasted_to(ChatChannel::STREAM).with(a_hash_including(html: a_string_including("Hello over the socket")))
  end

  it "escapes the message body in the broadcast HTML" do
    expect { perform :speak, body: "<script>alert(1)</script>" }
      .to have_broadcasted_to(ChatChannel::STREAM).with(a_hash_including(html: a_string_including("&lt;script&gt;")))
  end

  it "sends an invalid message's errors back to the sender only" do
    expect { perform :speak, body: "   " }
      .not_to have_broadcasted_to(ChatChannel::STREAM)

    expect(Message.count).to eq(0)
    expect(transmissions.last).to eq("error" => "Body can't be blank")
  end
end

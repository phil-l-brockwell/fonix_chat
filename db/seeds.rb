# Demo data for development: two confirmed accounts and a short conversation.
# Sign in as alice@example.com or bob@example.com with the password "password123".
# Safe to run more than once.
return unless Rails.env.development?

alice, bob = %w[ alice@example.com bob@example.com ].map do |email_address|
  User.find_or_create_by!(email_address: email_address) do |user|
    user.password = "password123"
    user.confirmed_at = Time.current
  end
end

if Message.none?
  [
    [ bob, "Morning! Is the new chat working for you?", 3.days.ago ],
    [ alice, "Yes, messages arrive instantly.", 3.days.ago + 2.minutes ],
    [ bob, "Great. Try opening a second browser and signing in as me.", 2.days.ago ]
  ].each do |user, body, created_at|
    Message.create!(user: user, body: body, created_at: created_at)
  end
end

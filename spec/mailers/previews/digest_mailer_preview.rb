# Preview at http://localhost:3000/rails/mailers/digest_mailer
class DigestMailerPreview < ActionMailer::Preview
  def weekly
    DigestMailer.weekly(User.first || User.new(email_address: "preview@example.com", created_at: 1.month.ago), as_of: Time.current)
  end
end

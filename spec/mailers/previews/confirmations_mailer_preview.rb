# Preview at http://localhost:3000/rails/mailers/confirmations_mailer
class ConfirmationsMailerPreview < ActionMailer::Preview
  def confirm
    ConfirmationsMailer.confirm(User.first || User.new(id: 0, email_address: "preview@example.com"))
  end
end

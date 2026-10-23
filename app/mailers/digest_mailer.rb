class DigestMailer < ApplicationMailer
  helper :digest

  def weekly(user, as_of:)
    @digest = WeeklyDigest.new(user, as_of: as_of)
    mail subject: "Your week on Fonix Chat", to: user.email_address
  end
end

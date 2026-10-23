# Emails every confirmed user their weekly digest. All digests from one run
# are counted up to the same moment, however long delivery takes.
class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(as_of: Time.current)
    User.confirmed.find_each do |user|
      DigestMailer.weekly(user, as_of: as_of).deliver_later
    end
  end
end

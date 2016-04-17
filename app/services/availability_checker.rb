class AvailabilityChecker

  def self.call
    return unless Date.today.tuesday? && (Date.today.cweek % 2 == 0)

    Community.all.each do |community|
      community.listings.non_badge.currently_open.each do |listing|
        availabilities = Availability.unbooked(listing)

        next if availabilities.size > 3

        PersonMailer.insufficient_availabilities_to_author(community, listing).deliver
      end
    end
  end
end


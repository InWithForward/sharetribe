# == Schema Information
#
# Table name: availabilities
#
#  id              :integer          not null, primary key
#  listing_id      :integer
#  start_at_hour   :integer
#  start_at_minute :integer
#  end_at_hour     :integer
#  end_at_minute   :integer
#  dow             :integer
#  date            :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Availability < ActiveRecord::Base
  WEEKS = 4*4

  belongs_to :listing

  attr_accessible :transaction_id, :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute, :dow, :date

  validates :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute, presence: true

  def start_at=(time)
    self.start_at_hour = time.hour
    self.start_at_minute = time.min
  end

  def end_at=(time)
    self.end_at_hour = time.hour
    self.end_at_minute = time.min
  end

  def self.unbooked(listing)
    bookings = Booking.joins(:transaction).
      where(transactions: { listing_id: listing.id }).
      where('start_at > ?', Time.now).
      where(confirmed: true).
      map { |booking| {
        start_at: booking.start_at.to_time,
        end_at: booking.end_at.to_time
      } }

    recurring = listing.availabilities.where('dow is not null').map do |availability|
      synthesize availability
    end.flatten(1)

    singles = listing.availabilities.where('dow is null').map do |availability|
      d = availability.date
      {
        start_at: Time.new(d.year, d.month, d.day, availability.start_at_hour, availability.start_at_minute, 0),
        end_at: Time.new(d.year, d.month, d.day, availability.end_at_hour, availability.end_at_minute, 0)
      }
    end

    (recurring + singles) - bookings
  end

  def self.synthesize(availability)
    WEEKS.times.map do |i|
      t = Date.today
      d = Date.commercial(t.cwyear, t.cweek, (availability.dow + 1))
      d += i.week

      {
        start_at: Time.new(d.year, d.month, d.day, availability.start_at_hour, availability.start_at_minute, 0),
        end_at: Time.new(d.year, d.month, d.day, availability.end_at_hour, availability.end_at_minute, 0)
      }
    end
  end
end

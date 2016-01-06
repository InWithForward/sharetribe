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
#  recurring       :boolean          default(FALSE)
#
# Indexes
#
#  index_availabilities_on_date        (date)
#  index_availabilities_on_listing_id  (listing_id)
#

class Availability < ActiveRecord::Base
  WEEKS = 4*4

  belongs_to :listing

  attr_accessible :transaction_id, :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute, :date, :recurring

  validates :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute, :date, presence: true

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

    availabilities = listing.availabilities.where(date: Date.today..(Date.today + WEEKS.weeks)).map do |availability|
      d = availability.date
      {
        start_at: Time.new(d.year, d.month, d.day, availability.start_at_hour, availability.start_at_minute, 0),
        end_at: Time.new(d.year, d.month, d.day, availability.end_at_hour, availability.end_at_minute, 0)
      }
    end

    availabilities - bookings
  end
end

require 'spec_helper'

describe BookingReminderToRequesterJob do

  def create_custom_field(keys)
    keys.each do |key|
      question = FactoryGirl.create(:question, key: key, community: community)
      question.categories << listing.category
    end
  end

  let(:community) { FactoryGirl.create(:community, domain: 'lvh.me') }

  let!(:person) { FactoryGirl.create(:person) }

  let!(:location) { FactoryGirl.create(:location) }
  let!(:listing) { FactoryGirl.create(:listing, author: person, location: location) }
  let!(:transaction) { FactoryGirl.create(:transaction, listing: listing) }
  let!(:booking) { FactoryGirl.create(:free_booking, transaction: transaction, confirmed: true) }

  it "sends an sms" do
    create_custom_field [:bring_money, :what_else, :location_details, :nearest_skytrain_station]

    expect(SmsJob).to receive(:new).and_return(double(perform: nil))

    described_class.new(booking.id, community.id, :confirmation).perform
  end

end

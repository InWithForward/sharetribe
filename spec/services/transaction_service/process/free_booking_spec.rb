require 'spec_helper'

describe TransactionService::Process::FreeBooking do
  let(:community) { FactoryGirl.create(:community) }

  let!(:person) do
    FactoryGirl.create(:person)
  end

  let!(:location) { FactoryGirl.create(:location) }
  let!(:listing) { FactoryGirl.create(:listing, author: person, location: location) }
  let!(:transaction) do
    FactoryGirl.create(:transaction, listing: listing).tap do |tx|
      conversation = tx.build_conversation(
        community_id: community.id,
        listing_id: listing.id
      )
      conversation.participations.build(
        person_id: listing.author.id,
        is_starter: false,
        is_read: false
      )
      tx.save
    end
  end

  let!(:bookings) do
    [
      FactoryGirl.create(:free_booking, transaction: transaction),
      FactoryGirl.create(:free_booking, transaction: transaction)
    ]
  end

  before do
    {
      location_details: 'location',
      bring_money: 'bring money',
      what_else: 'what else',
      nearest_skytrain_station: 'nearest station'
    }.each_pair do |key, value|
      question = FactoryGirl.create(:question, key: key)
      custom_field_value = FactoryGirl.create(:custom_field_value, text_value: value, question: question)
      question.categories << listing.category
    end

    MarketplaceService::Transaction::Command.transition_to(transaction.id, :requested)
  end

  describe '#confirm' do

    it 'sends out reminders' do
      described_class.new.confirm(booking: bookings.first)
      Timecop.freeze(48.hours.from_now)
      successes, failures = Delayed::Worker.new.work_off
      expect(ActionMailer::Base.deliveries.count).to eql(4)
    end

  end

end

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

  let(:booking) { bookings.first }

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

    before do
      allow(SmsJob).to receive(:new).and_return(double(perform: true))
    end

    it 'sends out reminders' do
      described_class.new.confirm(booking: booking)
      Timecop.freeze(48.hours.from_now)
      expect{ 
        successes, failures = Delayed::Worker.new(quiet: false).work_off
      }.to change { ActionMailer::Base.deliveries.count }.by(4)
    end

    it 'creates a Trello card' do
      expect(CreateTrelloCardJob).to receive(:new).and_return(double(perform: true))
      described_class.new.confirm(booking: booking)
    end

    it 'sends out an sms reminder' do
      address = ", at #{location.address}"
      body = I18n.t('sms.booking_reminder', title: listing.title, time: booking.start_at.strftime('%a, %b %d %l:%M'), address: address)

      expect(SmsJob).to receive(:new)
        .with(person.phone_number, nil, body)
        .and_return(double(perform: true))

      described_class.new.confirm(booking: booking)
    end

    context 'when there is no location' do
      before do
        listing.location = nil
        listing.save
      end

      it 'sends out an sms reminder' do
        body = I18n.t('sms.booking_reminder', title: listing.title, time: booking.start_at.strftime('%a, %b %d %l:%M'), address: '')

        expect(SmsJob).to receive(:new)
          .with(person.phone_number, nil, body)
          .and_return(double(perform: true))

        described_class.new.confirm(booking: booking)
      end

    end

  end

end

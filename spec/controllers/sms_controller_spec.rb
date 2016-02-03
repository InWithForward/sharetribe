require 'spec_helper'

describe SmsController, type: :controller do
  describe "#accept" do
    let(:community) { FactoryGirl.create(:community) }

    let!(:person) do
      FactoryGirl.create(:person, phone_number: '+1 555-555-5555').tap do |person|
        community.members << person
      end
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
      @request.host = "#{community.ident}.lvh.me"
      MarketplaceService::Transaction::Command.transition_to(transaction.id, :requested)
    end

    it "books the passed in time" do
      post :accept, { 'Body' => "#{transaction.id}-#{bookings[0].id}", 'From' => '+15555555555' }
      expect(response.status).to eql(200)
      expect(bookings[0].reload).to be_confirmed
    end

    it "books rebooks if 0" do
      post :accept, { 'Body' => "#{transaction.id}-0", 'From' => '+15555555555' }
      expect(response.status).to eql(200)
      expect(transaction.reload.status).to eql("canceled")
    end

    it 'ignores request from different number' do
      post :accept, { 'Body' => "#{transaction.id}-0", 'From' => '6042890319' }
      expect(response.status).to eql(404)
    end
  end
end

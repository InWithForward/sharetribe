require 'spec_helper'

describe SmsController do
  describe "#accept" do
    let(:community) { FactoryGirl.create(:community) }

    let!(:person) do
      FactoryGirl.create(:person).tap do |person|
        community.members << person
      end
    end

    let!(:listing) { FactoryGirl.create(:listing) }
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
      post :accept, { 'Body' => "#{transaction.id}-#{bookings[0].id}", 'From' => '+12062890319' }
      expect(bookings[0].reload).to be_confirmed
      expect(response.status).to eql(200)
    end

    it "books rebooks if 0" do
      post :accept, { 'Body' => "#{transaction.id}-0", 'From' => '+12062890319' }
      expect(transaction.reload.status).to eql("canceled")
      expect(response.status).to eql(200)
    end

    it 'ignores request from different number' do
      post :accept, { 'Body' => "#{transaction.id}-0", 'From' => '6042890319' }
      expect(response.status).to eql(404)
    end
  end
end

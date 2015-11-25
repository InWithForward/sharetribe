
require 'spec_helper'

describe AvailabilityChecker do

  subject { described_class.call }

  let!(:membership) do
    FactoryGirl.create(
      :community_membership,
      community: listing.communities.first,
      admin: true
    )
  end

  let!(:listing) { FactoryGirl.create(:listing) }

  let(:time) { Time.new(2014, 3, 12, 0, 0, 0, 0) }

  before do
    Timecop.freeze(time)
  end

  let(:delivery_stub) { double(deliver: true) }

  def expect_emails
    expect(PersonMailer).to receive(:insufficient_availabilities_to_admin) { delivery_stub }
    expect(PersonMailer).to receive(:insufficient_availabilities_to_author) { delivery_stub }
  end

  def dont_expect_emails
    expect(PersonMailer).not_to receive(:insufficient_availabilities_to_admin)
    expect(PersonMailer).not_to receive(:insufficient_availabilities_to_author)
  end

  it "sends emails" do
    expect_emails
    subject
  end

  context 'when the listing is closed' do
    let!(:listing) { FactoryGirl.create(:listing, open: false) }

    it "does not send emails" do
      dont_expect_emails;
      subject
    end
  end

  context 'when the listing is a badge' do
    let!(:listing) do
      listing = FactoryGirl.create(:listing)
      listing.transaction_type = FactoryGirl.create(:transaction_type_badge)
      listing.save
      listing
    end

    it "does not send emails" do
      dont_expect_emails
      subject
    end
  end

  context 'when the listing has availabilities' do
    # Since this is recurring, it will be more than enough availabilities
    let!(:availability) { FactoryGirl.create(:availability, listing: listing, dow: 1, date: time.to_date) }

    it "does not send emails" do
      dont_expect_emails
      subject
    end
  end

  context 'when the day is not a send day' do
    let(:time) { Time.new(2014, 3, 14, 0, 0, 0, 0) }

    it "does not send emails" do
      dont_expect_emails
      subject
    end
  end
end

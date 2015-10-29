require 'spec_helper'

def find_email_body_for(email)
  ActionMailer::Base.deliveries.select do |e|
    e.to.first == email.address
  end.first
end

describe TransactionMailer do

  # Include EmailSpec stuff (https://github.com/bmabey/email-spec)
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)

  describe "#canceled_booking_to_admin" do
    let(:reason) { "Didnt work out" }

    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @c1.community_customizations.first.update_attribute(:name, "MarketTestPlace")

      @p1 = FactoryGirl.create(:person)
      @p1.communities << @c1

      @admin = FactoryGirl.create(:person,
                                  :is_admin => true,
                                  :emails => [ FactoryGirl.create(:email, :address => "admin@example.com") ])
      @admin.communities << @c1
      @c1.community_memberships.where(:person_id => @admin.id).update_all("admin = 1")

      @email = described_class.canceled_booking_to_admin(@p1, @p1.communities.first, reason)
    end

    it "should have correct address and subject" do
      @email.should deliver_to("admin@example.com")
      @email.should have_subject("Canceled Booking")
    end

    it "should have correct links" do
      @email.should have_body_text(/.*#{@p1.name}.*/)
      @email.should have_body_text(/.*#{reason}.*/)
    end
  end
end

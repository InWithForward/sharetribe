require 'spec_helper'

describe BookingReminderToRequesterJob do

  def create_custom_field(key, value)
    question = FactoryGirl.create(:question, key: key, community: community)
    question.categories << listing.category
    FactoryGirl.create(
      :text_field_value,
      customizable: listing,
      question: question,
      text_value: value
    )
  end

  let(:community) { FactoryGirl.create(:community, domain: 'lvh.me') }

  let!(:person) { FactoryGirl.create(:person) }

  let!(:listing) { FactoryGirl.create(:listing, author: person) }
  let!(:transaction) { FactoryGirl.create(:transaction, listing: listing) }
  let!(:booking) { FactoryGirl.create(:free_booking, transaction: transaction, confirmed: true) }

  let(:date) { booking.start_at.to_date.to_formatted_s(:long) }
  let(:time) { booking.start_at.strftime("%I:%M %p") }
  let(:author_name) { PersonViewUtils.person_display_name(transaction.author, community) }

  def sends_the_correct_message(message)
    expect(SmsJob).to receive(:new)
      .with(person.phone_number, nil, message)
      .and_return(double(perform: nil))

    described_class.new(booking.id, community.id, :confirmation).perform
  end

  it "sends an sms" do
    message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "
    message << "Please bring: Your smart phone or iPod"

    sends_the_correct_message(message)
  end

  context 'when transaction is canceled' do
    it "doesn't send the sms " do
      transaction.current_state = :canceled
      transaction.save!
      expect(SmsJob).not_to receive(:new)

      described_class.new(booking.id, community.id, :confirmation).perform
    end
  end

  context 'when a location is provided' do
    let!(:location) { FactoryGirl.create(:location) }
    let!(:listing) { FactoryGirl.create(:listing, author: person, location: location) }

    it "sends an sms" do
      message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "
      message << "The address: #{location.address}. "
      message << "Please bring: Your smart phone or iPod"

      sends_the_correct_message(message)
    end
  end

  context 'when a location details are provided' do
    let(:value) { "location details" }

    before do
      create_custom_field(:location_details, value)
    end

    it "sends an sms" do
      message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "
      message << "The location details: #{value}. "
      message << "Please bring: Your smart phone or iPod"

      sends_the_correct_message(message)
    end
  end

  context 'when nearest skytrain is provided' do
    let(:value) { "Burnaby Station" }

    before do
      create_custom_field(:nearest_skytrain_station, value)
    end

    it "sends an sms" do
      message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "
      message << "Nearest skytrain station: #{value}. "
      message << "Please bring: Your smart phone or iPod"

      sends_the_correct_message(message)
    end
  end

  context 'when what_else is provided' do
    let(:value) { "snowboard" }

    before do
      create_custom_field(:what_else, value)
    end

    it "sends an sms" do
      message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "
      message << "Please bring: Your smart phone or iPod, #{value}."

      sends_the_correct_message(message)
    end
  end

end

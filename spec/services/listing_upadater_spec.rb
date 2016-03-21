require 'spec_helper'

describe ListingUpdater do
  let!(:listing) { FactoryGirl.create(:listing) }

  it "updates the main object" do
    expect {
      described_class.call(listing, { listing: { title: 'New Title' } })
    }.to change(listing, :title)
  end

  it 'updates the location' do
    FactoryGirl.create(:location, listing: listing)

    expect {
      described_class.call(listing, { location: { address: 'New Address' } })
    }.to change(listing.location, :address)
  end

  it 'updates the custom fields' do
    custom_field_value = FactoryGirl.create :text_field_value,
      question: FactoryGirl.create(:custom_text_field)
    listing = custom_field_value.customizable

    expect {
      described_class.call(listing, { custom_fields: { custom_field_value.question.id => 'New Value'} })
    }.to change {
      custom_field_value.reload.text_value
    }
  end

  it 'updates availabilities' do
    params = {
      listing: {
        availabilities_attributes: [{
          start_at_hour: 9,
          start_at_minute: 30,
          end_at_hour: 11,
          end_at_minute: 0,
          date: Date.today,
          recurring: true
        }]
      }
    }

    FactoryGirl.create(:availability, listing: listing)

    expect {
      described_class.call(listing, params)
    }.to change{
      listing.availabilities.reload.first.start_at_hour
    }
  end

  it 'rolls back on error' do
    availability = FactoryGirl.create(:availability, listing: listing)

    params = {
      listing: {
        availabilities_attributes: [{
          id: availability.id,
          start_at_hour: 9,
          start_at_minute: 30,
          end_at_hour: 11,
          end_at_minute: 0,
          date: Date.today,
          recurring: true
        }]
      }
    }

    expect {
      described_class.call(listing, params)
    }.to raise_error(Exception)

    expect(listing.availabilities.reload).not_to be_empty
  end

  it 'rolls back on listing error' do
    availability = FactoryGirl.create(:availability, listing: listing)
    params = {
      listing: {
        title: "",
        availabilities_attributes: [{
          start_at_hour: 9,
          start_at_minute: 30,
          end_at_hour: 11,
          end_at_minute: 0,
          date: Date.today,
          recurring: true
        }]
      }
    }

    described_class.call(listing, params)
    expect(listing.availabilities.reload).not_to be_empty
  end

end


require 'spec_helper'

describe Admin::CommunityListingsController, type: :controller do

  let(:community) { FactoryGirl.create(:community) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    sign_in_for_spec(create_admin_for(community))
  end

  describe "#index" do
    let!(:listing) { FactoryGirl.create(:listing, communities: [community], category: checkbox_field.categories.first) }
    let(:checkbox_field) { FactoryGirl.create(:custom_checkbox_field, key: 'prerequisites') }

    let!(:checkbox_field_value) { FactoryGirl.create(:checkbox_field_value, customizable: listing, question: checkbox_field) }

    it 'exports as csv' do
      get :index, id: community.id, format: :csv
      csv_string = ArrayToCSV.generate(ListingCSV, [listing])
      expect(response.body).to eql(csv_string)
    end
  end

end

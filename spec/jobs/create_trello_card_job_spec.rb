require 'spec_helper'

describe CreateTrelloCardJob do
  let(:community) { FactoryGirl.create(:community, domain: 'lvh.me') }

  let!(:person) { FactoryGirl.create(:person) }

  let!(:custom_field_value) do
    question = FactoryGirl.create(:question, key: :transport_needed, community: community)
    dropdown = FactoryGirl.create(:dropdown_field_value, question: question, customizable: transaction.starter)
    option = dropdown.selected_options.first
    option.title_attributes = { en: "Yes" }
    option.save
  end

  let!(:location) { FactoryGirl.create(:location) }
  let!(:listing) { FactoryGirl.create(:listing, author: person, location: location) }
  let!(:transaction) { FactoryGirl.create(:transaction, listing: listing) }
  let!(:booking) { FactoryGirl.create(:free_booking, transaction: transaction, confirmed: true) }

  def stub_trello(path)
    stub_request(:post, Trello::BASE_URL + '/1' + path).
      with(query: hash_including(Trello::CREDENTIALS)).
      and_return(body: { id: 1 }.to_json)
  end

  before do
    stub_trello("/cards")
    stub_trello("/cards/1/attachments")
    stub_trello("/cards/1/checklists")
    stub_trello("/cards/1/checklist/1/checkItem")
  end

  it "creates a trello card" do
    described_class.new(booking.id, community.id).perform
    expect(stub_trello("/cards")).to have_been_made
  end

end

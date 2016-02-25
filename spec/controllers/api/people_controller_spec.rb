require 'spec_helper'

describe Api::PeopleController, type: :controller do

  describe 'show' do
    let!(:person) { FactoryGirl.create(:person) }
    let!(:listing) { FactoryGirl.create(:listing) }
    let!(:transaction) { FactoryGirl.create(:transaction, starter: person, listing: listing, current_state: :booked) }
    let!(:booking) { FactoryGirl.create(:free_booking, transaction: transaction, start_at: Time.now + 1.day, end_at: Time.now + 2.day, confirmed: true) }

    let!(:completed_listing) { FactoryGirl.create(:listing) }
    let!(:completed_transaction) { FactoryGirl.create(:transaction, starter: person, listing: completed_listing, current_state: :confirmed) }
    let!(:badge) { FactoryGirl.create(:badge, sub_listings: [completed_listing]) }

    let!(:text_field_value) { FactoryGirl.create(:text_field_value, customizable: person) }

    let!(:auth_token) { FactoryGirl.create(:auth_token, token_type: 'login') }

    let(:body) { HashUtils.deep_symbolize_keys(JSON.parse(response.body)) }

    let(:url) {
      Rails.application.routes.url_helpers.listing_url(
        host: listing.communities.first.full_domain,
        id: listing.id
      )
    }

    def name(p)
      PersonViewUtils.full_name(p.given_name, p.family_name)
    end

    it 'returns 401 if unauthorized' do
      get :show, id: listing.id, format: :json
      expect(response.status).to eql(401)
    end

    it 'returns json' do
      get :show, id: person.id, auth: auth_token.token, format: :json
      expect(body).to eql({
        data: {
          type: 'Person',
          id: person.id,
          attributes: {
            name: name(person),
            phone_number: person.phone_number,
            username: person.username,
            image_urls: {
              thumb: person.image.url(:thumb),
              big: person.image.url(:big)
            }
          },
          relationships: {
            custom_field_values: {
              data: [
                {
                  type: text_field_value.class.to_s,
                  id: text_field_value.id,
                  attributes: {
                    title: text_field_value.question.name,
                    value: text_field_value.text_value,
                    key: text_field_value.question.key
                  }
                }
              ]
            },
            booked_transactions: {
              data: [
                {
                  id: transaction.id,
                  type: transaction.class.to_s,
                  attributes: {
                    status: transaction.status.to_s,
                    created_at: transaction.created_at.iso8601,
                    start_at: transaction.booking.start_at.iso8601,
                    end_at: transaction.booking.end_at.iso8601,
                    reason: transaction.reason
                  },
                  relationships: {
                    listing: {
                      data: {
                        id: listing.id,
                        type: 'Listing',
                        attributes: {
                          title: listing.title,
                          description: listing.description,
                          created_at: listing.created_at.iso8601,
                          url: url
                        },
                        relationships: {
                          listing_images: { data: [] },
                          custom_field_values: { data: [] },
                          author: {
                            data: {
                              type: 'Person',
                              id: listing.author.id,
                              attributes: {
                                name: name(listing.author),
                                phone_number: listing.author.phone_number,
                                username: listing.author.username,
                                image_urls: {
                                  thumb: listing.author.image.url(:thumb),
                                  big: listing.author.image.url(:big)
                                }
                              },
                              relationships: {
                                custom_field_values: { data: [] }
                              }
                            }
                          },
                          location: { data: nil }
                        }
                      }
                    }
                  }
                }
              ]
            }
          }
        }
      })
    end
  end

end

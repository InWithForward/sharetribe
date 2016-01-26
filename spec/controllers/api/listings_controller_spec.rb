require 'spec_helper'

describe Api::ListingsController do

  describe 'show' do
    let!(:location) { FactoryGirl.create(:location) }
    let!(:listing) { FactoryGirl.create(:listing, location: location) }
    let!(:listing_image) { ListingImage.create(listing: listing) }

    let!(:text_field_value) { FactoryGirl.create(:text_field_value, customizable: listing) }
    let!(:checkbox_field_value) { FactoryGirl.create(:checkbox_field_value, customizable: listing) }

    let!(:author_text_field_value) { FactoryGirl.create(:text_field_value, customizable: listing.author) }

    before do
      listing.custom_field_values.each do |value|
        listing.category.custom_fields << value.question
      end
    end

    let(:body) { HashUtils.deep_symbolize_keys(JSON.parse(response.body)) }

    it 'returns json' do
      get :show, id: listing.id, format: :json
      expect(body).to eql({
        data: {
          id: listing.id,
          type: 'Listing',
          attributes: {
            title: listing.title,
            description: listing.description,
            created_at: listing.created_at.iso8601
          },
          relationships: {
            listing_images: {
              data: [
                { 
                  type: 'ListingImage',
                  id: listing_image.id,
                  attributes: {
                    image_urls: {
                      thumb: listing_image.image.url(:thumb),
                      big: listing_image.image.url(:big)
                    }
                  }
                }
              ]
            },
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
                },
                {
                  type: checkbox_field_value.class.to_s,
                  id: checkbox_field_value.id,
                  attributes: {
                    title: checkbox_field_value.question.name,
                    value: checkbox_field_value.selected_options.map(&:title),
                    key: checkbox_field_value.question.key
                  }
                }
              ]
            },
            author: {
              data: {
                type: 'Person',
                id: listing.author.id,
                attributes: {
                  name: listing.author.name,
                  image_urls: {
                    thumb: listing.author.image.url(:thumb),
                    big: listing.author.image.url(:big)
                  }
                },
                relationships: {
                  custom_field_values: {
                    data: [
                      {
                        type: author_text_field_value.class.to_s,
                        id: author_text_field_value.id,
                        attributes: {
                          title: author_text_field_value.question.name,
                          value: author_text_field_value.text_value,
                          key: author_text_field_value.question.key
                        }
                      }
                    ]
                  }
                }
              }
            },
            location: {
              data: {
                type: 'Location',
                id: listing.location.id,
                attributes: {
                  address: listing.location.address,
                  latitude: listing.location.latitude,
                  longitude: listing.location.longitude,
                  google_address: listing.location.google_address
                }
              }
            }
          }
        }
      })
    end
  end

end

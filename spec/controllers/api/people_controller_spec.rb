require 'spec_helper'

describe Api::PeopleController do

  describe 'show' do
    let!(:person) { FactoryGirl.create(:person) }

    let!(:text_field_value) { FactoryGirl.create(:text_field_value, customizable: person) }

    let(:body) { HashUtils.deep_symbolize_keys(JSON.parse(response.body)) }

    it 'returns json' do
      get :show, id: person.username, format: :json
      expect(body).to eql({
        data: {
          type: 'Person',
          id: person.id,
          attributes: {
            name: person.name,
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
            }
          }
        }
      })
    end
  end

end

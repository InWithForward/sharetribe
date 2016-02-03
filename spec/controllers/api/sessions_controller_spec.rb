
require 'spec_helper'

describe Api::SessionsController, type: :controller do

  describe 'create' do
    let!(:person) { FactoryGirl.create(:person) }

    let(:body) { HashUtils.deep_symbolize_keys(JSON.parse(response.body)) }

    it 'returns json' do
      post :create, person: { login: person.username, password: person.password }, format: :json
      expect(body).to eql({
        data: {
          type: 'session',
          id: person.auth_tokens.first.token,
          attributes: {
            person_id: person.id
          }
        }
      })
    end
  end

end

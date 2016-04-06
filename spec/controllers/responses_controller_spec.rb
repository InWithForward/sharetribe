require 'spec_helper'

describe ResponsesController, type: :controller do

  describe '#create' do
    let(:params) do
      {
        "MailboxHash" => "SampleHash",
        "TextBody" => "This is a test text body."
      }
    end

    it 'responds 200' do
      post :create, params
      expect(response.status).to eql(200)
    end

  end

end

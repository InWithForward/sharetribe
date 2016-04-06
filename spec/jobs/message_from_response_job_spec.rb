require 'spec_helper'

describe MessageFromResponseJob do
  let(:message) { FactoryGirl.create(:message) }
  let(:conversation) { FactoryGirl.create(:conversation, messages: [message]) }

  let(:mailbox_hash) do
    {
      c: conversation.id,
      s: conversation.messages.first.sender.id
    }
  end

  let(:params) do
    {
      "MailboxHash" => MailUtils.encode(mailbox_hash),
      "StrippedTextReply" => "Person's response"
    }
  end

  it 'creates a message' do
    expect {
      described_class.new(params).perform
    }.to change(conversation.messages, :count)
  end

  context 'when the conversation is not found' do
    let(:mailbox_hash) do
      {
        c: 0,
        s: conversation.messages.first.sender.id
      }
    end

    it 'raises an error' do
      expect {
        described_class.new(params).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

end

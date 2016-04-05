

require 'spec_helper'

describe Conversation do

  before(:each) do
    @participation = FactoryGirl.build(:participation)
  end

  it 'does not allow duplicate participants' do
    author = FactoryGirl.build(:person)

    participations = [
      FactoryGirl.build(:participation, person: author),
      FactoryGirl.build(:participation, person: author, is_starter: true)
    ]

    conversation = FactoryGirl.build(:conversation,
                                     participants: [author, author],
                                     participations: participations)

    expect(conversation.save).to eql(false)
  end

end

require 'spec_helper'

describe FieldValueCreator do

  let!(:custom_field_value) do
    FactoryGirl.create :text_field_value,
      question: FactoryGirl.create(:custom_text_field)
  end

  let(:listing) { custom_field_value.customizable }

  it "updates a listing's custom fields" do
    expect {
      FieldValueCreator.call({ custom_field_value.question.id => 'New Value'}, listing)
    }.to change {
      custom_field_value.reload.text_value
    }
  end

  context 'when custom_field is a checkbox field' do
    let!(:custom_field_value) do
      FactoryGirl.create :checkbox_field_value
    end

    let(:options) do
      custom_field_value.question.options
    end

    it "updates a listing's custom fields" do
      FieldValueCreator.call({ custom_field_value.question.id => options}, listing)
      expect(custom_field_value.custom_field_option_selections.reload.size).to eql(2)
    end
  end

  context 'when custom_field is a dropdown field' do
    let!(:custom_field_value) do
      FactoryGirl.create :dropdown_field_value
    end

    let(:options) do
      custom_field_value.question.options
    end

    it "updates a listing's custom fields" do
        expect {
          FieldValueCreator.call({ custom_field_value.question.id => options.first.id}, listing)
        }.to change {
          custom_field_value.custom_field_option_selections.reload.map { |s| s.id }
        }
    end
  end

end

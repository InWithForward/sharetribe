require 'spec_helper'

describe CustomFieldsHelper do

  describe '#custom_fields_hash' do
    let(:key) { 'key' }
    let(:value) { 'value' }
    let!(:question) { FactoryGirl.create(:question, key: key) }
    let!(:custom_field_value) { FactoryGirl.create(:custom_field_value, text_value: value, question: question) }
    let(:listing) { custom_field_value.customizable }

    subject { described_class.custom_fields_hash(listing) }

    before do
      custom_field_value.question.categories << listing.category
    end

    it 'has the custom field' do
      expect(subject).to eql({key.to_sym => value})
    end

    context 'when DropownField' do
      let!(:question) { FactoryGirl.create(:custom_dropdown_field, key: key) }
      let!(:custom_field_value) { FactoryGirl.create(:dropdown_field_value, question: question) }
      let(:value) { custom_field_value.selected_options.first.title(I18n.locale) }

      it 'has the custom field' do
        expect(subject).to eql({key.to_sym => value})
      end
    end

    context 'when DateField' do
      let!(:question) { FactoryGirl.create(:custom_date_field, key: key) }
      let!(:custom_field_value) { FactoryGirl.create(:date_field_value, question: question) }
      let(:value) { I18n.l(Time.now, format: :short_date) }

      it 'has the custom field' do
        expect(subject).to eql({key.to_sym => value})
      end
    end

    context 'when CheckboxFieldValue' do
      let!(:custom_field_value) { FactoryGirl.create(:checkbox_field_value, question: question) }

      it 'has the custom field' do
        expect(subject).to eql({key.to_sym => ''})
      end
    end

    context 'when NumericFieldValue' do
      let!(:custom_field_value) { FactoryGirl.create(:custom_numeric_field_value, question: question) }

      it 'has the custom field' do
        expect(subject).to eql({key.to_sym => 0})
      end
    end
  end
end

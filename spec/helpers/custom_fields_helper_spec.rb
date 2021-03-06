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

      context 'when no options' do
        before do
          custom_field_value.selected_options = []
        end

        it 'does not have the custom field' do
          expect(subject).to eql({key.to_sym => nil})
        end
      end
    end

    context 'when DateField' do
      let(:time) { Time.now }
      let!(:question) { FactoryGirl.create(:custom_date_field, key: key) }
      let!(:custom_field_value) { FactoryGirl.create(:date_field_value, question: question, date_value: time) }
        
      it 'has the custom field' do
        value = I18n.l(custom_field_value.date_value, format: :short_date)
        expect(subject).to eql({ key.to_sym => value })
      end
    end

    context 'when CheckboxFieldValue' do
      let!(:custom_field_value) { FactoryGirl.create(:checkbox_field_value, question: question) }

      it 'has the custom field' do
        expect(subject).to eql({key.to_sym => 'Test option'})
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

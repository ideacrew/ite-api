# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Record, type: :model, dbclean: :around_each do
  let(:provider) { FactoryBot.create(:provider, :with_extracts) }
  let(:extract) { provider.extracts.first }
  let(:valid_ssn) { '123456879' }

  let(:record_params) do
    { payload:
       { provider_id: '15',
         admission_id: '194062',
         admission_date: '01/04/2022',
         treatment_type: '4',
         client_id: 'LEVN46410511921',
         codependent: '2',
         dob: '05/11/4002',
         gender: '2',
         race: nil,
         ethnicity: '9',
         primary_language: '-1',
         num_of_prior_admissions: '2',
         arrests_past_30days: nil,
         ssn: valid_ssn,
         education: '12',
         employment: '3',
         last_contact_date: '05/11/4002' },
      extract_id: extract.id }
  end

  context 'with a valid payload' do
    before do
      @record = described_class.create(record_params)
    end

    it 'will create an record' do
      expect(@record.persisted?).to eq true
      expect(@record.class).to eq(described_class)
    end

    it 'will obscure the ssn with formatted last 4 digits in the details if 9 digits' do
      ssn = @record.details.dig('payload', 'ssn')
      expect(ssn).not_to eq valid_ssn
      expect(ssn).to eq '***-**-6879'
    end

    it 'will obscure the ssn with stars in the details if less than 9 digits' do
      @record.payload[:ssn] = '123'
      @record.save
      ssn = @record.reload.details.dig('payload', 'ssn')
      expect(ssn).not_to eq '123'
      expect(ssn).to eq '***'
      expect(ssn.length).to eq 3
    end

    it 'will obscure the ssn with stars in the details if greater than 9 digits' do
      @record.payload[:ssn] = '1232387463782647823647'
      @record.save
      ssn = @record.reload.details.dig('payload', 'ssn')
      expect(ssn).not_to eq '3647'
      expect(ssn).to eq '******************3647'
      expect(ssn.length).to eq 22
    end
  end

  context 'without a valid payload' do
    before do
      record_params[:payload] = nil
      @record = described_class.create(record_params)
    end

    it 'will create an record' do
      expect(@record.persisted?).to eq false
    end
  end
end

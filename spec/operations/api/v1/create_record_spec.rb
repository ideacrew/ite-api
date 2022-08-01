# frozen_string_literal: true

require 'rails_helper'

describe ::Operations::Api::V1::CreateRecord do
  include Dry::Monads[:result, :do]

  let(:extract_params) { FactoryBot.create(:extract) }

  let(:row) do
    { 'provider_id' => '15',
      'episode_id' => '194062',
      'admission_date' => Date.today.to_s,
      'treatment_type' => '4',
      'client_id' => 'LEVN46410511921',
      'collateral' => '1',
      'dob' => (Date.today - 3000).to_s,
      'num_of_prior_admissions' => '2',
      'arrests_past_30days' => nil,
      'education' => '12',
      'employment' => '3',
      'last_contact_date' => Date.today.to_s,
      'record_type' => 'A',
      'gender' => '1',
      'first_name' => 'George',
      'last_name' => 'Bluth',
      'race' => '1',
      'ethnicity' => '97',
      'primary_language' => '01' }
  end

  let(:params) do
    {
      extract: extract_params.attributes.symbolize_keys, payload: row
    }
  end

  context 'valid params' do
    before do
      @result = described_class.new.call(params)
      @record = @result.value!
    end

    it 'should be a success' do
      expect(@result).to be_success
    end

    it 'Should create record' do
      expect(@record).to be_a(::Api::V1::Record)
    end

    it 'Should have no failures or warnings' do
      expect(@record.failures).to eq([])
      expect(@record.warnings).to eq([])
    end

    it 'should have a status of Valid' do
      expect(@record.status).to eq('Valid')
    end
  end

  context 'invalid params' do
    context 'without a payload' do
      before do
        params[:payload] = nil
      end
      it 'should be a failure' do
        expect(described_class.new.call(params)).to be_failure
      end
      it 'should not create a record' do
        expect(described_class.new.call(params).failure).to_not be_a(::Api::V1::Record)
      end
    end

    context 'with invalid payload' do
      before do
        params[:payload][:episode_id] = nil
        @result = described_class.new.call(params)
        @record = @result.value!
      end
      it 'should create a record with a failure' do
        expect(@record.failures).to_not eq([])
      end

      it 'should have a status of Invalid' do
        expect(@record.status).to eq('Invalid')
      end
    end
  end
end

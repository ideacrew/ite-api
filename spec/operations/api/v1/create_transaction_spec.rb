# frozen_string_literal: true

require 'rails_helper'

describe ::Operations::Api::V1::CreateTransaction do
  include Dry::Monads[:result, :do]

  let(:extract) { FactoryBot.create(:extract) }

  let(:row) do
    { 'provider_id' => '15',
      'episode_id' => '194062',
      'admission_date' => '01/04/22',
      'treatment_type' => '4',
      'client_id' => 'LEVN46410511921',
      'codependent' => '2',
      'dob' => '05/11/4002',
      'gender' => '2',
      'race' => nil,
      'ethnicity' => '9',
      'primary_language' => '-1',
      'num_of_prior_admissions' => '2',
      'arrests_past_30days' => nil,
      'education' => '12',
      'employment' => '3',
      'last_contact_date' => '05/11/4002' }
  end

  let(:params) do
    {
      extract:, payload: row, data_type: 'csv'
    }
  end

  context 'valid params' do
    before do
      @result = described_class.new.call(params)
      @transaction = @result.value!
    end

    it 'should be a success' do
      expect(@result).to be_success
    end

    it 'Should create transaction' do
      expect(@transaction).to be_a(::Api::V1::Transaction)
    end

    it 'Should have no failures or warnings' do
      expect(@transaction.failures).to eq([])
      expect(@transaction.warnings).to eq([])
    end

    it 'should have a status of Valid' do
      expect(@transaction.status).to eq('Valid')
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
      it 'should not create a transaction' do
        expect(described_class.new.call(params).failure).to_not be_a(::Api::V1::Transaction)
      end
    end

    context 'with invalid payload' do
      before do
        params[:payload][:episode_id] = nil
        @result = described_class.new.call(params)
        @transaction = @result.value!
      end
      it 'should create a transaction with a failure' do
        expect(@transaction.failures).to_not eq([])
      end

      it 'should have a status of Invalid' do
        expect(@transaction.status).to eq('Invalid')
      end
    end
  end
end

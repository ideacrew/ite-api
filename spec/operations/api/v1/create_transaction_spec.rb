# frozen_string_literal: true

require 'rails_helper'

describe ::Operations::Api::V1::CreateTransaction do
  include Dry::Monads[:result, :do]

  let(:extract) { FactoryBot.create(:extract) }

  let(:row) do
    { 'provider_id' => '15',
      'episode_id' => '194062',
      'admission_date' => 'dfkgjhdfjghjk',
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
    it 'Should create transaction' do
      described_class.new.call(params)
    end

    it 'Should have no failures or warnings' do
      # described_class.new.call(params)
    end

    it 'should have a status of Valid' do
    end
  end

  context 'invalid params' do
    context 'without a payload' do
      it 'should not create a transaction' do
      end
    end
  end
end

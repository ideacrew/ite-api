# frozen_string_literal: true

require 'rails_helper'

describe ::Operations::Api::V1::CreateRecord, dbclean: :after_each do
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
      'num_of_prior_episodes' => '2',
      'arrests_past_30days' => nil,
      'treatment_location' => '123 main',
      'education' => '12',
      'employment' => '3',
      'last_contact_date' => Date.today.to_s,
      'record_type' => 'A',
      'referral_source' => '2',
      'primary_payment_source' => '2',
      'criminal_justice_referral' => '96',
      'gender' => '1',
      'first_name' => 'George',
      'last_name' => 'Bluth',
      'race' => '1',
      'ethnicity' => '97',
      'primary_language' => '1' }
  end

  let(:dups) { [1234] }

  let(:params) do
    {
      extract: extract_params.attributes.symbolize_keys, payload: row, dups:
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

    context 'with invalid key field' do
      before do
        params[:payload][:admission_date] = nil
        @result = described_class.new.call(params)
        @record = @result.value!
      end
      it 'should create a record with a failure' do
        expect(@record.failures).to_not eq([])
      end
      it 'should create a record without a warning' do
        expect(@record.warnings).to eq([])
      end

      it 'should have a status of Invalid' do
        expect(@record.status).to eq('Invalid')
      end
    end

    context 'with a missing discharge date' do
      it 'should create a record with a failure if the admission group is "discharge"' do
        params[:extract][:record_group] = 'discharge'
        params[:payload][:discharge_date] = nil
        record = described_class.new.call(params).value!
        expect(record.failures.map(&:keys).flatten).to include(:discharge_date)
        expect(record.warnings.map(&:keys).flatten).to_not include(:discharge_date)
      end
      it 'should create a record with a warnings if the admission group is not "discharge"' do
        params[:extract][:record_group] = 'admission'
        params[:payload][:discharge_date] = nil
        record = described_class.new.call(params).value!
        expect(record.failures.map(&:keys).flatten).to_not include(:discharge_date)
      end
    end

    context 'with duplicate episode id' do
      it 'should add an episode_id id failure' do
        params[:payload][:episode_id] = '1234'
        record = described_class.new.call(params).value!
        expect(record.failures.map(&:keys).flatten).to include(:episode_id)
        expect(record.failures.first[:episode_id]).to eq 'must be a unique identifier for admission episodes'
      end
    end

    context 'with an invalid last_contact_date date' do
      it 'should create a record with a failure if the admission group is "active"' do
        params[:extract][:record_group] = 'active'
        params[:payload][:last_contact_date] = 'not a date'
        record = described_class.new.call(params).value!
        expect(record.failures.map(&:keys).flatten).to include(:last_contact_date)
        expect(record.warnings.map(&:keys).flatten).to_not include(:last_contact_date)
      end
      it 'should create a record with a warnings if the admission group is not "discharge"' do
        params[:extract][:record_group] = 'admission'
        params[:payload][:last_contact_date] = 'not a date'
        record = described_class.new.call(params).value!
        expect(record.failures.map(&:keys).flatten).to_not include(:last_contact_date)
        expect(record.warnings.map(&:keys).flatten).to include(:last_contact_date)
      end
    end

    context 'with invalid non-key field' do
      before do
        params[:payload][:dob] = 'NotaDate'
        @result = described_class.new.call(params)
        @record = @result.value!
      end
      it 'should create a record with a failure' do
        expect(@record.failures).to eq([])
      end
      it 'should create a record without a warning' do
        expect(@record.warnings).to_not eq([])
      end
      it 'should have a status of Invalid' do
        expect(@record.status).to eq('Invalid')
      end
    end
  end
end

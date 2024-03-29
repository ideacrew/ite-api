# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ::Operations::Api::V1::IngestExtract, dbclean: :around_each do
  include Dry::Monads[:result, :do]

  let(:provider) { FactoryBot.create(:provider) }

  let(:records_array) { File.read('./spec/test_data/BHSD_Sample_PRD15-Jan-Admission.json') }

  let(:params) do
    {
      provider_gateway_identifier: provider.provider_gateway_identifier,
      coverage_start: '01-01-2022',
      coverage_end: '01-01-2022',
      extracted_on: '01-01-2022',
      file_name: 'extract_data',
      records: JSON.parse(records_array, symbolize_names: true)
    }
  end

  context 'valid params' do
    before do
      @result = described_class.new.call(params)
      @extract = @result.value!
    end
    it 'should be a success' do
      expect(@result).to be_success
    end
    it 'should create extract' do
      expect(@extract).to be_a(::Api::V1::Extract)
    end
    it 'extract should have records' do
      expect(@extract.records.count).to be > 0
    end
    it 'extract should have a status' do
      expect(@extract.status).to_not be_nil
    end
    it 'extract should have the same number of records as the records hash' do
      expect(@extract.records.length).to eq(params[:records].length)
    end
  end

  context 'invalid params' do
    context 'invalid extract' do
      before do
        params[:provider_gateway_identifier] = nil
      end
      it 'should be a failure' do
        expect(described_class.new.call(params)).to be_failure
      end
      it 'should not create a record' do
        expect(described_class.new.call(params).failure).to_not be_a(::Api::V1::Extract)
      end
    end

    context 'provider gateway identifier invalid' do
      before do
        params[:provider_gateway_identifier] = '123123324'
      end
      it 'should be a failure' do
        expect(described_class.new.call(params)).to be_failure
      end
      it 'should not create a record' do
        expect(described_class.new.call(params).failure).to_not be_a(::Api::V1::Extract)
      end
    end

    context 'invalid records' do
      before do
        params[:records].first[:admission_date] = nil
        @result = described_class.new.call(params)
        @extract = @result.value!
      end
      it 'should be a success' do
        expect(@result).to be_success
      end
      it 'should create extract' do
        expect(@extract).to be_a(::Api::V1::Extract)
      end
      it 'extract should have records' do
        expect(@extract.records.count).to be > 0
      end
      it 'extract should have a status of "invalid"' do
        expect(@extract.status).to eq('Invalid')
      end
      it 'extract should have the same number of records as the records hash' do
        expect(@extract.records.length).to eq(params[:records].length)
      end
    end

    context 'record with no values at all' do
      before do
        params[:records].first.update(params[:records].first) { |_key, _value| '' }
        @result = described_class.new.call(params)
        @extract = @result.value!
      end
      it 'should not create a record for a blank record' do
        expect(@extract.records.length).to eq(params[:records].length - 1)
      end
    end
  end
end

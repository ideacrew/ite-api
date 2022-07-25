# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ::Operations::Api::V1::IngestExtract do
  include Dry::Monads[:result, :do]

  let(:transactions_array) { File.read('./spec/test_data/BHSD_Sample_PRD15-Jan-Admission.json') }

  let(:payload) { './spec/test_data/BHSD_Sample_PRD15-Jan-Admission.csv' }

  let(:params) do
    {
      provider_gateway_identifier: '73982',
      coverage_start: '01-01-2022',
      coverage_end: '01-01-2022',
      extracted_on: '01-01-2022',
      file_name: 'extract_data',
      file_type: 'Initial',
      transaction_group: 'discharge',
      csv: File.new('./spec/test_data/BHSD_Sample_PRD15-Jan-Admission.csv', 'r'),
      transactions: transactions_array
    }
  end

  context 'valid params' do
    it 'Should create extract' do
      described_class.new.call(params)
    end
  end
end

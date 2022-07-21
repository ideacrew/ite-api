# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ::Operations::Api::V1::IngestExtract do
  include Dry::Monads[:result, :do]

  # let(:payload) {CSV.parse(File.read('./spec/test_data/ingest_extract_data.csv'), headers: true)}
  # let(:family_id) { JSON.parse(payload)["family_id"] }
  # let(:operation) { Operations::Api::v1::IngestExtract.new }

  # let(:params) do
  #   {
  #     :provider_identifier => "73982",
  #     :npi => "8372",
  #     :coverage_start => "01-01-2022",
  #     :coverage_end => "01-01-2022",
  #     :extracted_on => "01-01-2022",
  #     :file_name => "extract_data",
  #     :file_type => "Initial",
  #     :transaction_group => "Admmission"
  #     :csv =>
  #   }
  # end

  # context "valid params" do
  #   it 'Should create extract' do
  #     described_class.new.call(params)
  #   end
  # end
end

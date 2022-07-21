# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/extract_contract'

RSpec.describe ::Validators::Api::V1::ExtractContract do
  let(:required_params) do
    {
      provider_gateway_identifier: '73982',
      coverage_start: '01-01-2022',
      coverage_end: '01-01-2022',
      extracted_on: '01-01-2022',
      file_type: 'Initial',
      transaction_group: 'Admmission'
    }
  end

  context 'invalid parameters' do
    context 'with missing keys' do
      let(:missing_key_params) do
        {
          coverage_start: '01-01-2022',
          coverage_end: '01-01-2022',
          extracted_on: '01-01-2022',
          file_type: 'Initial',
          transaction_group: 'Admmission'
        }
      end

      it 'should list error for every bad parameter' do
        expect(subject.call(missing_key_params).errors.to_h.keys).not_to match_array missing_key_params.keys
      end
    end

    context 'Keys with missing values' do
      it 'should return failure' do
        required_params.merge!(provider_gateway_identifier: nil)
        expect(subject.call(required_params).errors.to_h).to eq({ provider_gateway_identifier: ['must be filled'] })
      end
    end

    context 'values with incorrect data type' do
      it 'should return failure' do
        required_params.merge!(provider_gateway_identifier: 128)
        expect(subject.call(required_params).errors.to_h).to eq({ provider_gateway_identifier: ['must be a string'] })
      end
    end
  end

  context 'valid parameters' do
    context 'with all required parameters' do
      it 'should pass validation' do
        result = subject.call(required_params)
        expect(result.success?).to be_truthy
        expect(result.to_h[:coverage_start].class).to eq Date
      end
    end

    context 'with all required and optional parameters' do
      it 'should pass validation' do
        required_params.merge!(file_name: 'Admission')
        result = subject.call(required_params)
        expect(result.success?).to be_truthy
      end
    end
  end
end

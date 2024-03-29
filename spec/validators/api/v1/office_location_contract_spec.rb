# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/office_location_contract'
require './app/domain/validators/api/v1/address_contract'

RSpec.describe ::Validators::Api::V1::OfficeLocationContract, dbclean: :around_each do
  let(:required_params) do
    {
      address:,
      phones: [phone]
    }
  end

  let(:optional_params) do
    {
      is_primary: true
    }
  end

  let(:email) { { address: 'test123@test.com' } }

  let(:phone) do
    {
      area_code: '101',
      number: '1234567',
      extension: '111'
    }
  end

  let(:address) do
    {
      address_line1: '123 main',
      city: 'Houlton',
      state: 'ME',
      zip: '04730'
    }
  end

  let(:all_params) { required_params.merge(optional_params) }

  context 'invalid parameters' do
    context 'with empty parameters' do
      it 'should list error for every required parameter' do
        expect(subject.call({}).errors.to_h.keys).to match_array required_params.keys
      end
    end

    context 'with optional parameters only' do
      it 'should list error for every required parameter' do
        expect(subject.call(optional_params).errors.to_h.keys).to match_array required_params.keys
      end
    end

    context 'Keys with missing values' do
      it 'should return failure' do
        all_params.merge!(address: nil)
        expect(subject.call(all_params).errors.to_h[:address]).to eq(['must be a hash'])
      end
    end
  end

  context 'valid parameters' do
    context 'with only required parameters' do
      it 'should pass validation' do
        result = subject.call(required_params)
        expect(result.success?).to be_truthy
      end
    end

    context 'with required and optional parameters' do
      it 'should pass validation' do
        result = subject.call(all_params)
        expect(result.success?).to be_truthy
      end
    end
  end
end

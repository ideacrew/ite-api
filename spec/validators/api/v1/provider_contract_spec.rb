# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/provider_contract'
require './app/domain/validators/api/v1/office_location_contract'

RSpec.describe ::Validators::Api::V1::ProviderContract, dbclean: :after_each do
  let(:required_params) do
    {
      provider_name: 'Acme Studio',
      npi: '0102030405',
      is_active: true,
      mh: true,
      sud: false,
      adult_care: true,
      child_care: false,
      office_locations: [office_location]
    }
  end

  let(:optional_params) do
    {
      provider_nick_name: 'Acme'
    }
  end

  let(:office_location) do
    {
      address:,
      phones: [phone],
      emails: [email]
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
        all_params[:provider_name] = nil
        expect(subject.call(all_params).errors.to_h[:provider_name]).to eq(['must be filled'])
      end
    end

    context 'invalid npi length' do
      it 'should fail if more than 10 characters' do
        all_params.merge!(npi: '23876487365743653489578457489758943785897843')
        expect(subject.call(all_params).errors.to_h[:npi]).to eq(['invalid npi with length not equal to 10 digits'])
      end
      it 'should fail if less than 10 characters' do
        all_params.merge!(npi: '2383')
        expect(subject.call(all_params).errors.to_h[:npi]).to eq(['invalid npi with length not equal to 10 digits'])
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

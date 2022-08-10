# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/address_contract'

RSpec.describe ::Validators::Api::V1::AddressContract, dbclean: :after_each do
  let(:required_params) do
    {
      address_line1: '123 main',
      city: 'Houlton',
      state: 'ME',
      zip: '04730'
    }
  end

  let(:optional_params) do
    {
      address_line2: 'Apt 2',
      dc_ward: 'Ward 1'
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
        all_params.merge!(city: nil)
        expect(subject.call(all_params).errors.to_h[:city]).to eq(['must be filled'])
      end
    end

    context 'invalid zop code length' do
      it 'should fail if more than 5 characters' do
        all_params.merge!(zip: '23876487365743657843')
        expect(subject.call(all_params).errors.to_h[:zip]).to eq(['invalid zip with length not equal to 5 digits'])
      end
      it 'should fail if less than 5 characters' do
        all_params.merge!(zip: '2383')
        expect(subject.call(all_params).errors.to_h[:zip]).to eq(['invalid zip with length not equal to 5 digits'])
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

# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/phone_contract'

RSpec.describe ::Validators::Api::V1::PhoneContract, dbclean: :after_each do
  let(:required_params) do
    {
      area_code: '101',
      number: '1234567'
    }
  end

  let(:optional_params) do
    {
      extension: '111'
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
        all_params.merge!(area_code: nil)
        expect(subject.call(all_params).errors.to_h[:area_code]).to eq(['must be filled'])
      end
    end

    context 'invalid area_code length' do
      it 'should fail if more than 3 characters' do
        all_params.merge!(area_code: '23876487365743657843')
        expect(subject.call(all_params).errors.to_h[:area_code]).to eq(['invalid area code with length not equal to 3 digits'])
      end
      it 'should fail if less than 3 characters' do
        all_params.merge!(area_code: '23')
        expect(subject.call(all_params).errors.to_h[:area_code]).to eq(['invalid area code with length not equal to 3 digits'])
      end
    end

    context 'invalid number length' do
      it 'should fail if more than 7 characters' do
        all_params.merge!(number: '23876487365743657843')
        expect(subject.call(all_params).errors.to_h[:number]).to eq(['invalid area code with length not equal to 7 digits'])
      end
      it 'should fail if less than 7 characters' do
        all_params.merge!(number: '23')
        expect(subject.call(all_params).errors.to_h[:number]).to eq(['invalid area code with length not equal to 7 digits'])
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

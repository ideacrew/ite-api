# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/extract_contract'

RSpec.describe ::Validators::Api::V1::ExtractContract, dbclean: :after_each do
  let(:required_params) do
    {
      provider_gateway_identifier: '73982',
      coverage_start: Date.today.to_s,
      coverage_end: Date.today.to_s,
      extracted_on: Date.today.to_s,
      file_type: 'Initial',
      transaction_group: 'admission'
    }
  end

  context 'invalid parameters' do
    context 'with missing keys' do
      let(:missing_key_params) do
        {
          coverage_start: Date.today.to_s,
          coverage_end: Date.today.to_s,
          extracted_on: Date.today.to_s,
          file_type: 'Initial',
          transaction_group: 'Admission'
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

    context 'invalid coverage dates' do
      context 'with coverage start date in the future' do
        it 'should fail validation' do
          required_params[:coverage_start] = Date.today + 1
          expect(subject.call(required_params).errors.to_h).to have_key(:coverage_start)
        end
      end

      context 'with coverage end date in the future' do
        it 'should fail validation' do
          required_params[:coverage_end] = Date.today + 1
          expect(subject.call(required_params).errors.to_h).to have_key(:coverage_end)
        end
      end

      context 'with coverage start date after coverage end date' do
        it 'should fail validation' do
          required_params[:coverage_start] = Date.today
          required_params[:coverage_end] = Date.today - 5
          expect(subject.call(required_params).errors.to_h).to have_key(:coverage_start)
        end
      end

      context 'with coverage start date more than 12 months greater than end date' do
        it 'should fail validation' do
          required_params[:coverage_end] = Date.today
          required_params[:coverage_start] = Date.today - 400
          expect(subject.call(required_params).errors.to_h).to have_key(:coverage_end)
        end
      end
    end

    context 'invalid extraction date' do
      context 'with extraction date in the future' do
        it 'should fail validation' do
          required_params[:extracted_on] = Date.today + 1
          expect(subject.call(required_params).errors.to_h).to have_key(:extracted_on)
        end
      end
    end

    context 'invalid transaction group' do
      context 'with transaction group not from list' do
        it 'should fail validation' do
          required_params[:transaction_group] = 'WrongOption'
          expect(subject.call(required_params).errors.to_h).to have_key(:transaction_group)
        end
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

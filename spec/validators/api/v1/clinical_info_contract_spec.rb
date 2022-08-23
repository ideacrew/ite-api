# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/clinical_info_contract'

RSpec.describe ::Validators::Api::V1::ClinicalInfoContract, dbclean: :around_each do
  let(:valid_params) do
    {
      smi_sed: '1',
      gaf_score_admission: '1',
      gaf_score_discharge: '1'
    }
  end

  context 'Passed with invalid params return error' do
    it 'with no smi_sed' do
      valid_params[:smi_sed] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:smi_sed)
      expect(result.errors.to_h[:smi_sed].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:smi_sed].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid smi_sed' do
      valid_params[:smi_sed] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:smi_sed)
      expect(result.errors.to_h[:smi_sed].first[:text]).to eq 'must be one of 1, 2, 3, 4, 97, 98'
      expect(result.errors.to_h[:smi_sed].first[:category]).to eq 'Invalid Value'
    end

    it 'with no gaf_score_admission' do
      valid_params[:gaf_score_admission] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gaf_score_admission)
      expect(result.errors.to_h[:gaf_score_admission].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:gaf_score_admission].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid gaf_score_admission' do
      valid_params[:gaf_score_admission] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gaf_score_admission)
      expect(result.errors.to_h[:gaf_score_admission].first[:text]).to eq 'must be one of 1-100, 997, 998'
      expect(result.errors.to_h[:gaf_score_admission].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid gaf_score_discharge' do
      valid_params[:gaf_score_discharge] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gaf_score_discharge)
      expect(result.errors.to_h[:gaf_score_discharge].first[:text]).to eq 'must be one of 1-100, 997, 998'
      expect(result.errors.to_h[:gaf_score_discharge].first[:category]).to eq 'Invalid Value'
    end
  end

  context 'Passed with valid required params' do
    it 'should see a success' do
      result = subject.call(valid_params)
      expect(result.success?).to be_truthy
    end
  end
end

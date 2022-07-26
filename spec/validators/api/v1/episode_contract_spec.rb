# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/episode_contract'

RSpec.describe ::Validators::Api::V1::EpisodeContract, dbclean: :after_each do
  let(:required_params) do
    {
      episode_id: 'fbgadfs7fgdy'
    }
  end

  let(:optional_params) do
    {
      codepedent: '44',
      admission_type: '31',
      admission_date: Date.today.to_s,
      treatment_type: '21',
      service_request_date: Date.today.to_s,
      discharge_date: Date.today.to_s,
      discharge_type: '50',
      discharge_reason: '34',
      last_contact_date: Date.today.to_s,
      num_of_prior_episodes: '3',
      referral_source: nil,
      criminal_justice_referral: '1',
      primary_payment_source: nil,
      client:,
      client_profile:,
      clinical_info:
    }
  end

  let(:all_params) { required_params.merge(optional_params) }

  let(:client) do
    {
      client_id: '8347ehf',
      first_name: 'John',
      middle_name: 'Danger',
      last_name: 'Doe',
      last_name_alt: '',
      alias: 'Johnny',
      ssn: '999999999',
      medicaid_id: '3498438978',
      dob: (Date.today - (20 * 365)).to_s,
      gender: '01',
      sexual_orientation: '48',
      race: '23',
      ethnicity: '9',
      primary_language: '3',
      phone1: '123456700',
      phone2: '349857674'
    }
  end

  let(:client_profile) do
    {
      client_id: '8347ehf',
      marital_status: '01',
      veteran_status: '01',
      education: '01',
      employment: '01',
      not_in_labor: '01',
      income_source: '01',
      pregnant: '01',
      school_attendance: '01',
      legal_status: '01',
      arrests_past_30days: '01',
      self_help_group_attendance: '01',
      health_insuranc: '01'
    }
  end

  let(:clinical_info) do
    {
      gaf_score: '16',
      smi_sed: '15',
      co_occurring_sud_mh: '13',
      opioid_therapy: '12',
      substance_problems: [{}],
      sud_diagnostic_codes: ['12'],
      mh_diagnostic_codes: ['19']
    }
  end

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
        all_params.merge!(episode_id: nil)
        expect(subject.call(all_params).errors.to_h).to eq({ episode_id: ['must be filled'] })
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

# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/episode_contract'

RSpec.describe ::Validators::Api::V1::EpisodeContract, dbclean: :after_each do
  let(:required_params) do
    {
      episode_id: 'fbgadfs7fgdy',
      admission_date: Date.today.to_s,
      treatment_type: '2',
      record_type: 'A'
    }
  end

  let(:optional_params) do
    {
      codepedent: '2',
      admission_type: '31',
      client_id: '8347ehf',
      service_request_date: Date.today.to_s,
      discharge_date: Date.today.to_s,
      discharge_type: '50',
      discharge_reason: '34',
      last_contact_date: Date.today.to_s,
      num_of_prior_episodes: '3',
      referral_source: nil,
      criminal_justice_referral: '1',
      primary_payment_source: nil,
      client: client_params,
      client_profile: client_profile_params,
      clinical_info: clinical_info_params
    }
  end

  let(:all_params) { required_params.merge(optional_params) }

  let(:client_params) do
    {
      client_id: '8347ehf',
      first_name: 'test',
      last_name: 'test',
      ssn: '000000000',
      medicaid_id: '162738',
      dob: Date.today,
      gender: '1',
      sexual_orientation: '2',
      race: '3',
      ethnicity: '4'
    }
  end

  let(:client_profile_params) do
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

  let(:clinical_info_params) do
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
        expect(subject.call(all_params).errors.to_h[:episode_id]).to eq(['must be filled'])
      end
    end

    context 'with invalid client id it should fail' do
      it 'with non-alphanumeric characters' do
        all_params[:client_id] = '237$!!'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('Field cannot contain special characters')
      end
      it 'with all 00s' do
        all_params[:client_id] = '000000'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('Cannot be all 0s')
      end
      it 'when longer than 15 characters' do
        all_params[:client_id] = '0000004389hfiugh4839g89righudhgdfhgj'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('Needs to be less than 16 digits')
      end
    end

    context 'codepedent field it should fail' do
      it 'with a value outside of accepted values' do
        all_params[:codepedent] = '304'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:codepedent)
        expect(errors[:codepedent].first).to eq('must be one of: 1, 2')
      end
      # A record of Codependent/Collateral requires Client ID and Admission Date information and reporting of
      # the remaining fields is optional.
      # For all items not reported, the data field should be coded with Not collected or Not applicable code.
    end

    context 'with invalid record_type field it should fail' do
      it 'is not present' do
        all_params[:record_type] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type]).to eq(['must be filled'])
      end
      it 'is not in the list of accepted values' do
        all_params[:record_type] = '29'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type]).to eq(['must be one of: A, T, D, M, X, E, U'])
      end
      it 'does not correctly correspond to the record_group' do
        all_params[:record_type] = 'U'
        all_params[:record_group] = 'admission'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type]).to eq(['must correspond to record group'])
      end
      # If this field is blank or contains a value that is not appropriate for the respective dataset
      # (A, T, M or X for [Admission] dataset, D, S or E for [Discharge] dataset, and U for [Active]
      # dataset), the record will fail to be processed as a valid record. A fatal error will be displayed
      # in the validation result.
      # The value of this field is related to the Treatment Setting and data in both fields need to
      # be consistent. For example, the record of a person with co-occurring mental illness admitted to a substance
      # use treatment must contain any of the codes 1-8 for Treatment Setting to assign a value of Initial Admission
      # for SU Treatment (A).
    end

    context 'with invalid admission_date field it should fail if' do
      it 'is not a date' do
        all_params[:admission_date] = 'twelve'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date]).to eq(['must be a date'])
      end
      it 'is not a valid date' do
        all_params[:admission_date] = 'February 30'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date]).to eq(['must be a date'])
      end
      it 'is a date before January 1, 1920' do
        all_params[:admission_date] = Date.new(1919, 0o1, 0o1).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('Must be after January 1, 1920')
      end
      it 'is after the date of last contact' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:last_contact_date] = (Date.today - 10)
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('Must be later than the date of last contact')
      end
      it 'is after the date of discharge' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:discharge_date] = (Date.today - 10).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors.to_h[:admission_date].first[:text]).to eq('Must be later than the date of discharge')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors.to_h[:admission_date].first[:text]).to eq('Must be later than the extraction date')
      end
    end

    context 'with invalid treatment_type field it should fail if' do
      it 'is nil and the extract record group type is discharge' do
        all_params[:treatment_type] = nil
        all_params[:record_group] = 'discharge'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first).to eq('must be filled')
      end
      it 'contains an invalid value' do
        all_params[:treatment_type] = 'Invalid'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first).to eq('must be one of: 1, 2, 3, 4, 5, 6, 7, 8, 72, 73, 74, 75, 76, 77, 96')
      end
      it 'does not correspond to the record_type' do
        all_params[:record_type] = 'M'
        all_params[:treatment_type] = '1'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first).to eq('must correspond to record_type')
        all_params[:record_type] = 'A'
        all_params[:treatment_type] = '72'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first).to eq('must correspond to record_type')
      end
    end

    context 'with invalid discharge date field it should fail' do
      it 'is not present in a Discharge record_group' do
        all_params[:discharge_date] = nil
        all_params[:record_group] = 'discharge'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('Must be included for discharge records')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first[:text]).to eq('Must be later than the extraction date')
      end

      it 'is later than the date of last contact' do
        all_params[:last_contact_date] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first[:text]).to eq('Must be later than the date of last contact')
      end

      it 'has a value when the record type is U' do
        all_params[:record_type] = 'U'
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        error_text = 'Must be blank if record type is Data Update for SU/MH Service (U)'
        expect(errors.to_h[:discharge_date].first[:text]).to eq(error_text)
      end
    end

    context 'with invalid last contact date field it should fail' do
      it 'is blank when the record_group is active' do
        all_params[:record_group] = 'active'
        all_params[:last_contact_date] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first).to eq('Must be included if is an active record')
      end
      it 'is blank when the record_group is admission or discharge with a warning' do
        all_params[:record_group] = 'admission'
        all_params[:last_contact_date] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first[:text]).to eq('Should be included')
        expect(errors.to_h[:last_contact_date].first[:warning]).to eq(true)
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:last_contact_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first[:text]).to eq('Must be later than the extraction date')
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

# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/episode_contract'

RSpec.describe ::Validators::Api::V1::EpisodeContract, dbclean: :after_each do
  let(:required_params) do
    {
      admission_date: Date.today.to_s,
      treatment_type: '2',
      collateral: '2',
      client_id: '8347ehf',
      treatment_location: '123 main',
      referral_source: '2',
      criminal_justice_referral: '96',
      record_type: 'A'
    }
  end

  let(:optional_params) do
    {
      admission_type: '31',
      episode_id: 'fbgadfs7fgdy',
      service_request_date: Date.today.to_s,
      # discharge_date: Date.today.to_s,
      discharge_type: '50',
      discharge_reason: '2',
      last_contact_date: Date.today.to_s,
      num_of_prior_episodes: '3',
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
      ssn: '123758027',
      medicaid_id: '16273833',
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
        all_params.merge!(admission_date: nil)
        expect(subject.call(all_params).errors.to_h[:admission_date]).to eq(['must be filled'])
      end
    end

    context 'with invalid client id it should fail' do
      it 'with non-alphanumeric characters' do
        all_params[:client_id] = '237$!!'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first).to eq('Field cannot contain special characters')
      end
      it 'with all 00s' do
        all_params[:client_id] = '000000'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first).to eq('Cannot be all 0s')
      end
      it 'when longer than 15 characters' do
        all_params[:client_id] = '0000004389hfiugh4839g89righudhgdfhgj'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first).to eq('Needs to be 15 or less characters')
      end
      it 'when not present' do
        all_params[:client_id] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id]).to include('must be filled')
      end
    end

    context 'codepedent/collateral field it should fail' do
      it 'with a value outside of accepted values' do
        all_params[:collateral] = '0'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:collateral)
        expect(errors[:collateral].first).to eq('must be one of: 1, 2')
      end
      it 'is not present' do
        all_params[:collateral] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:collateral)
        expect(errors[:collateral].first).to eq('must be filled')
      end
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
        expect(errors[:record_type]).to eq(['must be one of: A, T, D, M, X, E'])
      end
      it 'does not correctly correspond to the record_group' do
        all_params[:record_type] = 'D'
        all_params[:record_group] = 'admission'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type]).to eq(['must correspond to record group'])
      end
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
        expect(errors[:admission_date].first).to eq('Must be after January 1, 1920')
      end
      it 'is after the date of last contact' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:last_contact_date] = (Date.today - 10)
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first).to eq('Cannot be later than the date of last contact')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors.to_h[:admission_date].first).to eq('Cannot be later than the extraction date')
      end
      it 'is earlier than the coverage_start date' do
        all_params[:admission_date] = (Date.today - 10).to_s
        all_params[:coverage_start] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors.to_h[:admission_date].first).to eq('Must be within the coverage period of the dataset')
      end
      it 'is later than the coverage_end date' do
        all_params[:coverage_end] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors.to_h[:admission_date].first).to eq('Must be within the coverage period of the dataset')
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
      it 'uses code 96 and codepedent is false' do
        all_params[:treatment_type] = '96'
        all_params[:collateral] = '2'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type]).to include('can only specify 96 if client is Collateral/Codependent')
      end
    end

    context 'with invalid discharge date field it should fail' do
      it 'is not a date' do
        all_params[:discharge_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('must be a date')
      end
      it 'is not present in a Discharge record_group' do
        all_params[:discharge_date] = nil
        all_params[:record_group] = 'discharge'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('Must be included for discharge records')
      end
      it 'is present in an Admission or Active record_group' do
        all_params[:discharge_date] = Date.today.to_s
        all_params[:record_group] = 'admission'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('Must be blank if record group is admission or active')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('Must be earlier than the extraction date')
      end

      it 'is later than the date of last contact' do
        all_params[:last_contact_date] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first).to eq('Must be earlier than the date of last contact')
      end

      it 'is after the date of discharge' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:discharge_date] = (Date.today - 10).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date]).to include('Cannot be earlier than than the date of admission')
      end
    end

    context 'with invalid last contact date field it should fail' do
      it 'is blank when the record_group is active' do
        all_params[:record_group] = 'active'
        all_params[:last_contact_date] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first).to eq('must be included')
      end
      it 'is not a date' do
        all_params[:last_contact_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first).to eq('must be a date')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:last_contact_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first).to eq('Must be earlier than the data extraction date')
      end
      it 'is earlier than the date of admission' do
        all_params[:last_contact_date] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first).to eq('Cannot be earlier than the date of admission')
      end
    end
    context 'with invalid discharge reason field it should fail' do
      it 'is not present when the record group is discharge' do
        all_params[:discharge_reason] = nil
        all_params[:record_group] = 'discharge'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_reason)
        expect(errors.to_h[:discharge_reason].first).to eq('Must be included for discharge records')
      end
      it 'is not a valid discharge reason' do
        all_params[:discharge_reason] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_reason)
        expect(errors.to_h[:discharge_reason].first).to eq('must be one of: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 95, 97, 98')
      end
    end
    context 'with invalid episode_id it should fail' do
      it 'is more than 15 characters' do
        all_params[:episode_id] = '3478657436574865783465873465386gfueyg78r'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:episode_id)
        expect(errors.to_h[:episode_id]).to include('Needs to be 15 or less characters')
      end
    end
    context 'with invalid num_of_prior_episodes it should fail' do
      it 'is not present and the record group is not discharge' do
        all_params[:num_of_prior_episodes] = nil
        all_params[:record_group] = 'admission'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:num_of_prior_episodes)
        expect(errors.to_h[:num_of_prior_episodes].first).to eq('Must be included for admission or active records')
      end
      it 'is not a valid option' do
        all_params[:num_of_prior_episodes] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:num_of_prior_episodes)
        expect(errors.to_h[:num_of_prior_episodes].first).to eq('must be one of: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 97, 98')
      end
    end
    context 'with invalid treatment location' do
      it 'without treatment location' do
        all_params[:treatment_location] = nil
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:treatment_location)
        expect(result.errors.to_h[:treatment_location].first).to eq 'must be filled'
      end
    end
    context 'with invalid referral source' do
      it 'without referral source it should warn' do
        all_params[:referral_source] = nil
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:referral_source)
        expect(result.errors.to_h[:referral_source].first).to eq 'must be filled'
      end
      it 'is not a valid option it should fail' do
        all_params[:referral_source] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:referral_source)
        expect(errors.to_h[:referral_source].first).to eq('must be one of: 1, 2, 3, 4, 5, 6, 7, 97, 98')
      end
    end
    context 'with invalid criminal justice referral' do
      it 'is not a valid option it should fail' do
        all_params[:criminal_justice_referral] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:criminal_justice_referral)
        expect(errors.to_h[:criminal_justice_referral].first).to eq('must be one of: 1, 2, 3, 4, 5, 6, 7, 8, 96, 97, 98')
      end
      it 'without criminal justice referral it should warn' do
        all_params[:criminal_justice_referral] = nil
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first).to eq 'must be filled'
      end
      it 'without criminal_justice_referral  of 96 but with referral_source of 7 it should fail' do
        all_params[:criminal_justice_referral] = '96'
        all_params[:referral_source] = '7'
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first).to eq 'must be filled with a valid option if referral source is 7'
      end
      it 'referral_source is not 7, then criminal_justice_referral should be 96' do
        all_params[:criminal_justice_referral] = '1'
        all_params[:referral_source] = '1'
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first).to eq 'must be filled with 96 if referral source is not 7'
      end
    end
    context 'with invalid service_request_date' do
      it 'is not a date' do
        all_params[:service_request_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:service_request_date)
        expect(errors.to_h[:service_request_date].first).to eq('must be a date')
      end
      it 'is earlier than the date of admission' do
        all_params[:admission_date] = (Date.today - 10).to_s
        all_params[:service_request_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:service_request_date)
        expect(errors.to_h[:service_request_date].first).to eq('Cannot be later than the date of admission')
      end
    end

    # ones below check sub contracts
    context 'with invalid dob' do
      it 'fails if dob is after the admission date' do
        all_params[:client][:dob] = Date.today.to_s
        all_params[:admission_date] = (Date.today - 10).to_s
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:dob)
        expect(result.errors.to_h[:dob].first).to eq 'Must be later than the admission date'
      end
      it 'fails if dob is after the current date' do
        all_params[:client][:dob] = (Date.today + 10).to_s
        all_params[:admission_date] = (Date.today + 10).to_s
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:dob)
        expect(result.errors.to_h[:dob]).to include 'Must be later than the current date'
      end
    end
    # context 'with invalid gender' do
    #  it 'fails if male and pregnant' do
    #    all_params[:client][:gender] = '1'
    #    all_params[:client_profile][:pregnant] = '01'
    #    result = subject.call(all_params)
    #    expect(result.failure?).to be_truthy
    #    expect(result.errors.to_h).to have_key(:pregnant)
    #    expect(result.errors.to_h[:pregnant].first).to eq 'Gender is male, pregnancy is true'
    #  end
    # end
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

# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/episode_contract'

RSpec.describe ::Validators::Api::V1::EpisodeContract, dbclean: :around_each do
  let(:required_params) do
    {
      admission_date: Date.today.to_s,
      treatment_type: '2',
      collateral: '2',
      client_id: '8347ehf',
      treatment_location: '123 main',
      referral_source: '2',
      criminal_justice_referral: '96',
      num_of_prior_su_episodes: '3',
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
      discharge_date: Date.today.to_s,
      primary_payment_source: '1',
      last_contact_date: Date.today.to_s,
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
      ethnicity: '4',
      primary_language: '1'
    }
  end

  let(:client_profile_params) do
    {
      client_id: '8347ehf',
      marital_status: '1',
      veteran_status: '1',
      education: '1',
      employment: '1',
      not_in_labor: '1',
      income_source: '1',
      school_attendance: '1',
      legal_status: '1',
      arrests_past_30days: '1',
      pregnant: '2',
      self_help_group_attendance: '1',
      health_insuranc: '1'
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
        expect(subject.call(optional_params).errors.to_h.keys.flatten).to include(*required_params.keys)
      end
    end

    context 'Keys with missing values' do
      it 'should return failure' do
        all_params.merge!(admission_date: nil)
        errors = subject.call(all_params).errors.to_h
        expect(errors[:admission_date].first[:text]).to eq('Must be filled')
        expect(errors[:admission_date].first[:category]).to eq('Missing Value')
      end
    end

    context 'with invalid client id it should fail' do
      it 'with non-alphanumeric characters' do
        all_params[:client_id] = '237$!!'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('cannot contain special characters')
        expect(errors[:client_id].first[:category]).to eq('Invalid Field')
      end
      it 'with all 00s' do
        all_params[:client_id] = '000000'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('cannot contain all 0s')
        expect(errors[:client_id].first[:category]).to eq('Invalid Value')
      end
      it 'when longer than 15 characters' do
        all_params[:client_id] = '0000004389hfiugh4839g89righudhgdfhgj'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:client_id)
        expect(errors[:client_id].first[:text]).to eq('cannot contain more than 15 digits')
        expect(errors[:client_id].first[:category]).to eq('Invalid Field Length')
      end
      it 'when not present' do
        all_params.merge!(client_id: nil)
        errors = subject.call(all_params).errors.to_h
        expect(errors[:client_id].first[:text]).to eq('Must be filled')
        expect(errors[:client_id].first[:category]).to eq('Missing Value')
      end
    end

    context 'codepedent/collateral field it should fail' do
      it 'with a value outside of accepted values' do
        all_params[:collateral] = '0'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:collateral)
        expect(errors[:collateral].first[:text]).to eq('must be one of 1, 2')
        expect(errors[:collateral].first[:category]).to eq('Invalid Value')
      end
      it 'is not present' do
        all_params[:collateral] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:collateral)
        expect(errors[:collateral].first[:text]).to eq('Must be filled')
        expect(errors[:collateral].first[:category]).to eq('Missing Value')
      end
    end

    context 'with invalid record_type field it should fail' do
      it 'is not present' do
        all_params[:record_type] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type].first[:text]).to eq('Must be filled')
        expect(errors[:record_type].first[:category]).to eq('Missing Value')
      end
      it 'is not in the list of accepted values' do
        all_params[:record_type] = '29'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:record_type)
        expect(errors[:record_type].first[:text]).to eq('must be one of A, T, M, X')
        expect(errors[:record_type].first[:category]).to eq('Invalid Value')
      end
      # it 'does not correctly correspond to the record_group' do
      #   all_params[:record_type] = 'D'
      #   all_params[:record_group] = 'admission'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:record_type)
      #   expect(errors[:record_type]).to eq(['Must correspond to the submission dataset'])
      # end
    end

    context 'with invalid admission_date field it should fail if' do
      it 'is not a date' do
        all_params[:admission_date] = 'twelve'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('must be a valid date in format YYYY-mm-dd or mm/dd/YYYY')
        expect(errors[:admission_date].first[:category]).to eq('Wrong Format')
      end
      it 'is not a valid date' do
        all_params[:admission_date] = '2'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('must be a valid date in format YYYY-mm-dd or mm/dd/YYYY')
        expect(errors[:admission_date].first[:category]).to eq('Wrong Format')
      end
      it 'is a date before January 1, 1920' do
        all_params[:admission_date] = Date.new(1919, 0o1, 0o1).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('must be after January 1, 1920')
        expect(errors[:admission_date].first[:category]).to eq('Invalid Value')
      end
      it 'is after the date of last contact' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:last_contact_date] = (Date.today - 10)
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('cannot be later than the date of last contact')
        expect(errors[:admission_date].first[:category]).to eq('Data Inconsistency')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('cannot be later than the date of extraction')
        expect(errors[:admission_date].first[:category]).to eq('Data Inconsistency')
      end
      it 'is earlier than the coverage_start date' do
        all_params[:admission_date] = (Date.today - 10).to_s
        all_params[:coverage_start] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('must be within the coverage period of the dataset')
        expect(errors[:admission_date].first[:category]).to eq('Data Inconsistency')
      end
      it 'is later than the coverage_end date' do
        all_params[:coverage_end] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:admission_date)
        expect(errors[:admission_date].first[:text]).to eq('must be within the coverage period of the dataset')
        expect(errors[:admission_date].first[:category]).to eq('Data Inconsistency')
      end
    end

    context 'with invalid treatment_type field it should fail if' do
      # it 'is nil and the extract record group type is discharge' do
      #   all_params[:treatment_type] = nil
      #   all_params[:record_group] = 'discharge'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:treatment_type)
      #   expect(errors.to_h[:treatment_type].first).to eq('Must be filled')
      # end
      it 'contains an invalid value' do
        all_params[:treatment_type] = 'Invalid'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first[:text]).to eq('must be one of 1, 2, 3, 4, 5, 6, 7, 8, 72, 73, 74, 75, 76, 77, 96')
        expect(errors[:treatment_type].first[:category]).to eq('Invalid Value')
      end
      it 'does not correspond to the record_type' do
        all_params[:record_type] = 'M'
        all_params[:treatment_type] = '1'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first[:text]).to eq('must correspond to record_type')
        expect(errors[:treatment_type].first[:category]).to eq('Data Inconsistency')
        all_params[:record_type] = 'A'
        all_params[:treatment_type] = '72'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first[:text]).to eq('must correspond to record_type')
        expect(errors[:treatment_type].first[:category]).to eq('Data Inconsistency')
      end
      it 'uses code 96 and codepedent is true' do
        all_params[:record_type] = 'A'
        all_params[:treatment_type] = '96'
        all_params[:collateral] = '1'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to_not have_key(:treatment_type)
      end
      it 'uses code 96 and codepedent is false' do
        all_params[:treatment_type] = '96'
        all_params[:collateral] = '2'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:treatment_type)
        expect(errors.to_h[:treatment_type].first[:text]).to eq('can only specify 96 if client is Collateral/Codependent')
        expect(errors.to_h[:treatment_type].first[:category]).to eq('Data Inconsistency')
      end
    end

    context 'with invalid discharge date field it should fail' do
      it 'is not a date' do
        all_params[:discharge_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors[:discharge_date].first[:text]).to eq('must be a valid date in format YYYY-mm-dd or mm/dd/YYYY')
        expect(errors[:discharge_date].first[:category]).to eq('Wrong Format')
      end
      # it 'is not present in a Discharge record_group' do
      #   all_params[:discharge_date] = nil
      #   all_params[:record_group] = 'discharge'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:discharge_date)
      #   expect(errors.to_h[:discharge_date].first).to eq('Must be included for discharge records')
      # end
      # it 'is present in an Admission or Active record_group' do
      #   all_params[:discharge_date] = Date.today.to_s
      #   all_params[:record_group] = 'admission'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:discharge_date)
      #   expect(errors.to_h[:discharge_date].first).to eq('Should not be included for active or admission records')
      # end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors[:discharge_date].first[:text]).to eq('cannot be later than the date of extraction')
        expect(errors[:discharge_date].first[:category]).to eq('Data Inconsistency')
      end

      it 'is later than the coverage_end date' do
        all_params[:coverage_end] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors[:discharge_date].first[:text]).to eq('cannot be later than the coverage end')
        expect(errors[:discharge_date].first[:category]).to eq('Data Inconsistency')
      end

      it 'is later than the coverage_end date' do
        all_params[:discharge_reason] = '1'
        all_params[:discharge_date] = nil
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors[:discharge_date].first[:text]).to eq('cannot be empty when discharge reason is present')
        expect(errors[:discharge_date].first[:category]).to eq('Data Inconsistency')
      end

      it 'is later than the date of last contact' do
        all_params[:last_contact_date] = (Date.today - 10).to_s
        all_params[:discharge_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors[:discharge_date].first[:text]).to eq('cannot be later than the date of last contact')
        expect(errors[:discharge_date].first[:category]).to eq('Data Inconsistency')
      end

      it 'is after the date of discharge' do
        all_params[:admission_date] = Date.today.to_s
        all_params[:discharge_date] = (Date.today - 10).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_date)
        expect(errors.to_h[:discharge_date].first[:text]).to eq('cannot be earlier than the date of admission')
        expect(errors[:discharge_date].first[:category]).to eq('Data Inconsistency')
      end
    end

    context 'with invalid last contact date field it should fail' do
      # it 'is blank when the record_group is active' do
      #   all_params[:record_group] = 'active'
      #   all_params[:last_contact_date] = nil
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:last_contact_date)
      #   expect(errors.to_h[:last_contact_date].first).to eq('must be included')
      # end
      it 'is not a date' do
        all_params[:last_contact_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors[:last_contact_date].first[:text]).to eq('must be a valid date in format YYYY-mm-dd or mm/dd/YYYY')
        expect(errors[:last_contact_date].first[:category]).to eq('Wrong Format')
      end
      it 'is later than the extract_on date' do
        all_params[:extracted_on] = (Date.today - 10).to_s
        all_params[:last_contact_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors[:last_contact_date].first[:text]).to eq('cannot be later than the date of extraction')
        expect(errors[:last_contact_date].first[:category]).to eq('Data Inconsistency')
      end
      it 'is earlier than the date of admission' do
        all_params[:last_contact_date] = (Date.today - 10).to_s
        all_params[:admission_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:last_contact_date)
        expect(errors.to_h[:last_contact_date].first[:text]).to eq('cannot be earlier than the date of admission')
        expect(errors.to_h[:last_contact_date].first[:category]).to eq('Data Inconsistency')
      end
    end
    context 'with invalid discharge reason field it should fail' do
      # it 'is not present when the record group is discharge' do
      #   all_params[:discharge_reason] = nil
      #   all_params[:record_group] = 'discharge'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:discharge_reason)
      #   expect(errors.to_h[:discharge_reason].first).to eq('Must be included for discharge records')
      # end
      it 'is not a valid discharge reason' do
        all_params[:discharge_reason] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:discharge_reason)
        expect(errors.to_h[:discharge_reason].first[:text]).to eq('must be one of 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 95, 97, 98')
        expect(errors[:discharge_reason].first[:category]).to eq('Invalid Value')
      end
    end
    context 'with invalid episode_id it should fail' do
      it 'is more than 15 characters' do
        all_params[:episode_id] = '3478657436574865783465873465386gfueyg78r'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:episode_id)
        expect(errors.to_h[:episode_id].first[:text]).to eq('cannot contain more than 15 digits')
        expect(errors[:episode_id].first[:category]).to eq('Invalid Field Length')
      end
      it 'has special characters' do
        all_params[:episode_id] = '3478657436!@'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:episode_id)
        expect(errors.to_h[:episode_id].first[:text]).to eq('cannot contain special characters')
        expect(errors[:episode_id].first[:category]).to eq('Invalid Field')
      end
    end
    context 'with invalid num_of_prior_su_episodes it should fail' do
      # it 'is not present and the record group is not discharge' do
      #   all_params[:num_of_prior_su_episodes] = nil
      #   all_params[:record_group] = 'admission'
      #   errors = subject.call(all_params).errors.to_h
      #   expect(errors).to have_key(:num_of_prior_su_episodes)
      #   expect(errors.to_h[:num_of_prior_su_episodes].first).to eq('Must be included for admission or active records')
      # end
      it 'is not a valid option' do
        all_params[:num_of_prior_su_episodes] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:num_of_prior_su_episodes)
        expect(errors.to_h[:num_of_prior_su_episodes].first[:text]).to eq('must be one of 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 97, 98')
        expect(errors[:num_of_prior_su_episodes].first[:category]).to eq('Invalid Value')
      end
    end
    context 'with invalid treatment location' do
      it 'without treatment location' do
        all_params[:treatment_location] = nil
        result = subject.call(all_params)
        expect(result.errors.to_h).to have_key(:treatment_location)
        expect(result.errors.to_h[:treatment_location].first[:text]).to eq('Must be filled')
        expect(result.errors.to_h[:treatment_location].first[:category]).to eq('Missing Value')
      end
    end
    context 'with invalid referral source' do
      it 'without referral source it should warn' do
        all_params[:referral_source] = nil
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:referral_source)
        expect(result.errors.to_h[:referral_source].first[:text]).to eq 'Must be filled'
        expect(result.errors.to_h[:referral_source].first[:category]).to eq('Missing Value')
      end
      it 'is not a valid option it should fail' do
        all_params[:referral_source] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:referral_source)
        expect(errors[:referral_source].first[:text]).to eq('must be one of 1, 2, 3, 4, 5, 6, 7, 97, 98')
        expect(errors[:referral_source].first[:category]).to eq('Invalid Value')
      end
    end
    context 'with invalid criminal justice referral' do
      it 'is not a valid option it should fail' do
        all_params[:criminal_justice_referral] = '22'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:criminal_justice_referral)
        expect(errors[:criminal_justice_referral].first[:text]).to eq('must be one of 1, 2, 3, 4, 5, 6, 7, 8, 96, 97, 98')
        expect(errors[:criminal_justice_referral].first[:category]).to eq('Invalid Value')
      end
      it 'without criminal justice referral it should warn' do
        all_params[:criminal_justice_referral] = nil
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first[:text]).to eq 'Must be filled'
        expect(result.errors.to_h[:criminal_justice_referral].first[:category]).to eq('Missing Value')
      end
      it 'without criminal_justice_referral of 96 but with referral_source of 7 it should fail' do
        all_params[:criminal_justice_referral] = '96'
        all_params[:referral_source] = '7'
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first[:text]).to eq 'Should be one of 1-8 or 97-98'
        expect(result.errors.to_h[:criminal_justice_referral].first[:category]).to eq 'Data Inconsistency'
      end
      it 'referral_source is not 7, then criminal_justice_referral should be 96' do
        all_params[:criminal_justice_referral] = '1'
        all_params[:referral_source] = '1'
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:criminal_justice_referral)
        expect(result.errors.to_h[:criminal_justice_referral].first[:text]).to eq 'Should be Not Applicable (96)'
        expect(result.errors.to_h[:criminal_justice_referral].first[:category]).to eq 'Data Inconsistency'
      end
    end
    context 'with invalid service_request_date' do
      it 'is not a date' do
        all_params[:service_request_date] = 'Not a date'
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:service_request_date)
        expect(errors[:service_request_date].first[:text]).to eq('must be a valid date in format YYYY-mm-dd or mm/dd/YYYY')
        expect(errors[:service_request_date].first[:category]).to eq 'Wrong Format'
      end
      it 'is earlier than the date of admission' do
        all_params[:admission_date] = (Date.today - 10).to_s
        all_params[:service_request_date] = Date.today.to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:service_request_date)
        expect(errors[:service_request_date].first[:text]).to eq('cannot be later than the date of admission')
        expect(errors[:service_request_date].first[:category]).to eq 'Data Inconsistency'
      end
    end

    context 'with invalid primary_payment_source' do
      it 'is an invalid value' do
        all_params[:primary_payment_source] = (Date.today - 10).to_s
        errors = subject.call(all_params).errors.to_h
        expect(errors).to have_key(:primary_payment_source)
        expect(errors.to_h[:primary_payment_source].first[:text]).to eq('must be one of 1, 2, 3, 4, 5, 6, 7, 8, 9, 97, 98')
        expect(errors.to_h[:primary_payment_source].first[:category]).to eq('Invalid Value')
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
        expect(result.errors.to_h[:dob].first[:text]).to eq 'cannot be earlier than the date of admission'
        expect(result.errors.to_h[:dob].first[:category]).to eq 'Data Inconsistency'
      end
      it 'fails if dob is after the current date' do
        all_params[:client][:dob] = (Date.today + 10).to_s
        all_params[:admission_date] = (Date.today + 10).to_s
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:dob)
        expect(result.errors.to_h[:dob].first[:text]).to eq 'cannot be earlier than today'
        expect(result.errors.to_h[:dob].first[:category]).to eq 'Data Inconsistency'
      end
    end
    context 'with invalid gender' do
      it 'fails if male and pregnant' do
        all_params[:client][:gender] = '1'
        all_params[:client_profile][:pregnant] = '1'
        result = subject.call(all_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:pregnant)
        expect(result.errors.to_h[:pregnant].first[:text]).to eq 'gender is male, pregnancy is true'
        expect(result.errors.to_h[:pregnant].first[:category]).to eq 'Data Inconsistency'
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

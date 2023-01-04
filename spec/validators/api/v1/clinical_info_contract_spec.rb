# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/clinical_info_contract'

RSpec.describe ::Validators::Api::V1::ClinicalInfoContract, dbclean: :around_each do
  let(:valid_params) do
    {
      smi_sed: '2',
      gaf_score_admission: '3',
      gaf_score_discharge: '2',
      sud_dx1: 'F14.8393',
      mh_dx1: 'F24.8393',
      collateral: '1',
      primary_substance: '3',
      primary_su_frequency_admission: '2',
      primary_su_age_at_first_use: '2',
      opioid_therapy: '97',
      primary_su_route: '2'
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

    it 'with invalid primary_substance' do
      valid_params[:primary_substance] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_substance)
      expect(result.errors.to_h[:primary_substance].first[:text]).to eq 'must be one of 1-18, 20, 96-98'
      expect(result.errors.to_h[:primary_substance].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing primary_substance and sud_dx1 is valid' do
      valid_params[:primary_substance] = nil
      valid_params[:sud_dx1] = 'F14.8393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_substance)
      expect(result.errors.to_h[:primary_substance].first[:text]).to eq 'Must be filled when valid sud_dx1'
      expect(result.errors.to_h[:primary_substance].first[:category]).to eq 'Missing Value'
    end

    it 'with missing primary_substance and sud_dx1 is 999.9996' do
      valid_params[:primary_substance] = nil
      valid_params[:sud_dx1] = '999.9996'
      result = subject.call(valid_params)
      expect(result.success?).to be_truthy
      expect(result.errors.to_h).not_to have_key(:primary_substance)
    end

    it 'with invalid secondary_substance' do
      valid_params[:secondary_substance] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_substance)
      expect(result.errors.to_h[:secondary_substance].first[:text]).to eq 'must be one of 1-18, 20, 96-98'
      expect(result.errors.to_h[:secondary_substance].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid tertiary_substance' do
      valid_params[:tertiary_substance] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_substance)
      expect(result.errors.to_h[:tertiary_substance].first[:text]).to eq 'must be one of 1-18, 20, 96-98'
      expect(result.errors.to_h[:tertiary_substance].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid primary_su_frequency_discharge' do
      valid_params[:primary_su_frequency_discharge] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_frequency_discharge)
      expect(result.errors.to_h[:primary_su_frequency_discharge].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:primary_su_frequency_discharge].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid secondary_su_frequency_discharge' do
      valid_params[:secondary_su_frequency_discharge] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_frequency_discharge)
      expect(result.errors.to_h[:secondary_su_frequency_discharge].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:secondary_su_frequency_discharge].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid tertiary_su_frequency_discharge' do
      valid_params[:tertiary_su_frequency_discharge] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_frequency_discharge)
      expect(result.errors.to_h[:tertiary_su_frequency_discharge].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:tertiary_su_frequency_discharge].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid primary_su_age_at_first_use' do
      valid_params[:primary_su_age_at_first_use] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_age_at_first_use)
      expect(result.errors.to_h[:primary_su_age_at_first_use].first[:text]).to eq 'must be one of 1-98'
      expect(result.errors.to_h[:primary_su_age_at_first_use].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing primary_su_age_at_first_use and primary_substance present' do
      valid_params[:primary_su_age_at_first_use] = nil
      valid_params[:primary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_age_at_first_use)
      expect(result.errors.to_h[:primary_su_age_at_first_use].first[:text]).to eq 'Must be filled when primary_substance is 2-18 or 20'
      expect(result.errors.to_h[:primary_su_age_at_first_use].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid tertiary_su_age_at_first_use' do
      valid_params[:tertiary_su_age_at_first_use] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_age_at_first_use)
      expect(result.errors.to_h[:tertiary_su_age_at_first_use].first[:text]).to eq 'must be one of 1-98'
      expect(result.errors.to_h[:tertiary_su_age_at_first_use].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid secondary_su_age_at_first_use' do
      valid_params[:secondary_su_age_at_first_use] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_age_at_first_use)
      expect(result.errors.to_h[:secondary_su_age_at_first_use].first[:text]).to eq 'must be one of 1-98'
      expect(result.errors.to_h[:secondary_su_age_at_first_use].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing secondary_su_age_at_first_use and secondary_substance present' do
      valid_params[:secondary_su_age_at_first_use] = nil
      valid_params[:secondary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_age_at_first_use)
      expect(result.errors.to_h[:secondary_su_age_at_first_use].first[:text]).to eq 'Must be filled when valid associated substance present'
      expect(result.errors.to_h[:secondary_su_age_at_first_use].first[:category]).to eq 'Missing Value'
    end

    it 'with missing tertiary_su_age_at_first_use and tertiary_substance present' do
      valid_params[:tertiary_su_age_at_first_use] = nil
      valid_params[:tertiary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_age_at_first_use)
      expect(result.errors.to_h[:tertiary_su_age_at_first_use].first[:text]).to eq 'Must be filled when valid associated substance present'
      expect(result.errors.to_h[:tertiary_su_age_at_first_use].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid primary_su_route' do
      valid_params[:primary_su_route] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_route)
      expect(result.errors.to_h[:primary_su_route].first[:text]).to eq 'must be one of 1-4, 20, 96-98'
      expect(result.errors.to_h[:primary_su_route].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid tertiary_su_route' do
      valid_params[:tertiary_su_route] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_route)
      expect(result.errors.to_h[:tertiary_su_route].first[:text]).to eq 'must be one of 1-4, 20, 96-98'
      expect(result.errors.to_h[:tertiary_su_route].first[:category]).to eq 'Invalid Value'
    end

    it 'with invalid secondary_su_route' do
      valid_params[:secondary_su_route] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_route)
      expect(result.errors.to_h[:secondary_su_route].first[:text]).to eq 'must be one of 1-4, 20, 96-98'
      expect(result.errors.to_h[:secondary_su_route].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing primary_su_route and primary_substance present' do
      valid_params[:primary_su_route] = nil
      valid_params[:primary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_route)
      expect(result.errors.to_h[:primary_su_route].first[:text]).to eq 'Must be filled when valid associated substance present'
      expect(result.errors.to_h[:primary_su_route].first[:category]).to eq 'Missing Value'
    end

    it 'with missing secondary_su_route and secondary_substance present' do
      valid_params[:secondary_su_route] = nil
      valid_params[:secondary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_route)
      expect(result.errors.to_h[:secondary_su_route].first[:text]).to eq 'Must be filled when valid associated substance present'
      expect(result.errors.to_h[:secondary_su_route].first[:category]).to eq 'Missing Value'
    end

    it 'with missing tertiary_su_route and tertiary_substance present' do
      valid_params[:tertiary_su_route] = nil
      valid_params[:tertiary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_route)
      expect(result.errors.to_h[:tertiary_su_route].first[:text]).to eq 'Must be filled when valid associated substance present'
      expect(result.errors.to_h[:tertiary_su_route].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid primary_su_frequency_admission' do
      valid_params[:primary_su_frequency_admission] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_frequency_admission)
      expect(result.errors.to_h[:primary_su_frequency_admission].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:primary_su_frequency_admission].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing primary_su_frequency_admission and primary_substance is valid' do
      valid_params[:primary_su_frequency_admission] = nil
      valid_params[:primary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:primary_su_frequency_admission)
      expect(result.errors.to_h[:primary_su_frequency_admission].first[:text]).to eq 'Must be filled when primary_substance is 2-18 or 20'
      expect(result.errors.to_h[:primary_su_frequency_admission].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid secondary_su_frequency_admission' do
      valid_params[:secondary_su_frequency_admission] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_frequency_admission)
      expect(result.errors.to_h[:secondary_su_frequency_admission].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:secondary_su_frequency_admission].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing secondary_su_frequency_admission and primary_substance is valid' do
      valid_params[:secondary_su_frequency_admission] = nil
      valid_params[:secondary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:secondary_su_frequency_admission)
      expect(result.errors.to_h[:secondary_su_frequency_admission].first[:text]).to eq 'Must be filled when valid secondary_substance'
      expect(result.errors.to_h[:secondary_su_frequency_admission].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid tertiary_su_frequency_admission' do
      valid_params[:tertiary_su_frequency_admission] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_frequency_admission)
      expect(result.errors.to_h[:tertiary_su_frequency_admission].first[:text]).to eq 'must be one of 1-5, 96-98'
      expect(result.errors.to_h[:tertiary_su_frequency_admission].first[:category]).to eq 'Invalid Value'
    end

    it 'with missing tertiary_su_frequency_admission and primary_substance is valid' do
      valid_params[:tertiary_su_frequency_admission] = nil
      valid_params[:tertiary_substance] = '2'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:tertiary_su_frequency_admission)
      expect(result.errors.to_h[:tertiary_su_frequency_admission].first[:text]).to eq 'Must be filled when valid tertiary_substance'
      expect(result.errors.to_h[:tertiary_su_frequency_admission].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid co_occurring_sud_mh' do
      valid_params[:co_occurring_sud_mh] = 'not a real status'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:co_occurring_sud_mh)
      expect(result.errors.to_h[:co_occurring_sud_mh].first[:text]).to eq 'must be one of 1, 2, 97, 98'
      expect(result.errors.to_h[:co_occurring_sud_mh].first[:category]).to eq 'Invalid Value'
    end

    it 'with mismatched co_occurring_sud_mh' do
      valid_params[:co_occurring_sud_mh] = '2'
      valid_params[:record_type] = 'M'
      valid_params[:sud_dx1] = 'F14.8393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:co_occurring_sud_mh)
      expect(result.errors.to_h[:co_occurring_sud_mh].first[:text]).to eq 'must be 1 if MH record and sud_dx1 is applicable'
      expect(result.errors.to_h[:co_occurring_sud_mh].first[:category]).to eq 'Data Inconsistency'
    end

    context 'sud_dx1' do
      it 'with nil sud_dx1' do
        valid_params[:sud_dx1] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx1)
        expect(result.errors.to_h[:sud_dx1].first[:text]).to eq 'Must be filled'
        expect(result.errors.to_h[:sud_dx1].first[:category]).to eq 'Missing Value'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:sud_dx1] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx1)
        expect(result.errors.to_h[:sud_dx1].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:sud_dx1].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:sud_dx1] = '999.9996'
        valid_params[:collateral] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx1)
        expect(result.errors.to_h[:sud_dx1].first[:text]).to eq "cannot be non applicable with a record type as 'A'/'T' and collateral as 2"
        expect(result.errors.to_h[:sud_dx1].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx1)
        expect(result.errors.to_h[:sud_dx1].first[:text]).to eq "cannot be with a record type as 'M'/'X' and co occurring sud mh not 1"
        expect(result.errors.to_h[:sud_dx1].first[:category]).to eq 'Data Inconsistency'
      end
    end

    context 'sud_dx2' do
      before do
        valid_params[:sud_dx2] = 'F14.8393'
      end

      it 'without sud_dx1' do
        valid_params[:sud_dx1] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx2)
        expect(result.errors.to_h[:sud_dx2].first[:text]).to eq 'cannot have sud_dx2 without sud_dx1'
        expect(result.errors.to_h[:sud_dx2].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:sud_dx2] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx2)
        expect(result.errors.to_h[:sud_dx2].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:sud_dx2].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:sud_dx2] = '999.9996'
        valid_params[:collateral] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx2)
        expect(result.errors.to_h[:sud_dx2].first[:text]).to eq "cannot be non applicable with a record type as 'A'/'T' and collateral as 2"
        expect(result.errors.to_h[:sud_dx2].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx2)
        expect(result.errors.to_h[:sud_dx2].first[:text]).to eq "cannot be with a record type as 'M'/'X' and co occurring sud mh not 1"
        expect(result.errors.to_h[:sud_dx2].first[:category]).to eq 'Data Inconsistency'
      end
    end

    context 'sud_dx3' do
      before do
        valid_params[:sud_dx3] = 'F14.8393'
      end

      it 'without sud_dx1 and sud_dx_2' do
        valid_params[:sud_dx1] = nil
        valid_params[:sud_dx2] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx3)
        expect(result.errors.to_h[:sud_dx3].first[:text]).to eq 'cannot have sud_dx2 without sud_dx1 and sud_dx2'
        expect(result.errors.to_h[:sud_dx3].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:sud_dx3] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx3)
        expect(result.errors.to_h[:sud_dx3].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:sud_dx3].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:sud_dx3] = '999.9996'
        valid_params[:collateral] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx3)
        expect(result.errors.to_h[:sud_dx3].first[:text]).to eq "cannot be non applicable with a record type as 'A'/'T' and collateral as 2"
        expect(result.errors.to_h[:sud_dx3].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:sud_dx3)
        expect(result.errors.to_h[:sud_dx3].first[:text]).to eq "cannot be with a record type as 'M'/'X' and co occurring sud mh not 1"
        expect(result.errors.to_h[:sud_dx3].first[:category]).to eq 'Data Inconsistency'
      end
    end

    context 'mh_dx1' do
      it 'with nil sud_dx1' do
        valid_params[:mh_dx1] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq 'Must be filled'
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Missing Value'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:mh_dx1] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:mh_dx1] = '999.9996'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq "cannot be non applicable with a record type as 'M'/'X'"
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq "cannot be with a record type as 'A'/'T' and co occurring sud mh not 1"
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Data Inconsistency'
      end

      it 'starts with F1' do
        valid_params[:mh_dx1] = 'F11'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with F1 and has 8 digits' do
        valid_params[:mh_dx1] = 'F11.2343'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx1)
        expect(result.errors.to_h[:mh_dx1].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx1].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with G1 and has 8 digits' do
        valid_params[:mh_dx1] = 'G11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx1)
      end

      it 'starts with G1 and has 3 digits' do
        valid_params[:mh_dx1] = 'G11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx1)
      end

      it 'starts with Z1 and has 8 digits' do
        valid_params[:mh_dx1] = 'Z11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx1)
      end

      it 'starts with Z1 and has 3 digits' do
        valid_params[:mh_dx1] = 'Z11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx1)
      end
    end

    context 'mh_dx2' do
      before do
        valid_params[:mh_dx2] = 'F24.8393'
      end

      it 'without mh_dx1' do
        valid_params[:mh_dx1] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq 'cannot have mh_dx2 without mh_dx1'
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:mh_dx2] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:mh_dx2] = '999.9996'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq "cannot be non applicable with a record type as 'M'/'X'"
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq "cannot be with a record type as 'A'/'T' and co occurring sud mh not 1"
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Data Inconsistency'
      end

      it 'starts with F1' do
        valid_params[:mh_dx2] = 'F11'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with F1 and has 8 digits' do
        valid_params[:mh_dx2] = 'F11.2343'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx2)
        expect(result.errors.to_h[:mh_dx2].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx2].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with G1 and has 8 digits' do
        valid_params[:mh_dx2] = 'G11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx2)
      end

      it 'starts with G1 and has 3 digits' do
        valid_params[:mh_dx2] = 'G11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx2)
      end

      it 'starts with Z1 and has 8 digits' do
        valid_params[:mh_dx2] = 'Z11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx2)
      end

      it 'starts with Z1 and has 3 digits' do
        valid_params[:mh_dx2] = 'Z11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx2)
      end
    end

    context 'mh_dx3' do
      before do
        valid_params[:mh_dx3] = 'F24.8393'
      end

      it 'without mh_dx3' do
        valid_params[:mh_dx1] = nil
        valid_params[:mh_dx2] = nil
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq 'cannot have mh_dx2 without mh_dx1 and mh_dx2'
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with invalid co_occurring_sud_mh' do
        valid_params[:mh_dx3] = 'not a  status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq 'should have length between 3 and 8'
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Invalid Field Length'
      end

      it 'with record_type and collateral mismatch' do
        valid_params[:mh_dx3] = '999.9996'
        valid_params[:record_type] = 'M'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq "cannot be non applicable with a record type as 'M'/'X'"
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with record_type and co_occurring_sud_mh mismatch' do
        valid_params[:co_occurring_sud_mh] = '2'
        valid_params[:record_type] = 'A'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq "cannot be with a record type as 'A'/'T' and co occurring sud mh not 1"
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Data Inconsistency'
      end

      it 'starts with F1' do
        valid_params[:mh_dx3] = 'F11'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with F1 and has 8 digits' do
        valid_params[:mh_dx3] = 'F11.2343'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:mh_dx3)
        expect(result.errors.to_h[:mh_dx3].first[:text]).to eq "should start with F then not 1 with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:mh_dx3].first[:category]).to eq 'Invalid Value'
      end

      it 'starts with G1 and has 8 digits' do
        valid_params[:mh_dx3] = 'G11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx3)
      end

      it 'starts with G1 and has 3 digits' do
        valid_params[:mh_dx3] = 'G11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx3)
      end

      it 'starts with Z1 and has 8 digits' do
        valid_params[:mh_dx3] = 'Z11.2343'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx3)
      end

      it 'starts with Z1 and has 3 digits' do
        valid_params[:mh_dx3] = 'Z11'
        result = subject.call(valid_params)
        expect(result.success?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:mh_dx3)
      end
    end

    context 'non_bh_dx1 non_bh_dx2 non_bh_dx3' do
      it 'invalid non_bh_dx1' do
        valid_params[:non_bh_dx1] = 'F14.8393'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:non_bh_dx1)
        expect(result.errors.to_h[:non_bh_dx1].first[:text]).to eq "should not start with F, with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:non_bh_dx1].first[:category]).to eq 'Invalid Value'
      end

      it 'invalid non_bh_dx1' do
        valid_params[:non_bh_dx2] = 'F14.8393'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:non_bh_dx2)
        expect(result.errors.to_h[:non_bh_dx2].first[:text]).to eq "should not start with F, with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:non_bh_dx2].first[:category]).to eq 'Invalid Value'
      end

      it 'invalid non_bh_dx1' do
        valid_params[:non_bh_dx3] = 'F14.8393'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:non_bh_dx3)
        expect(result.errors.to_h[:non_bh_dx3].first[:text]).to eq "should not start with F, with length between 3 and 8 with or without character '.' after 3 digits"
        expect(result.errors.to_h[:non_bh_dx3].first[:category]).to eq 'Invalid Value'
      end
    end

    context 'opioid_therapy' do
      it 'with invalid opioid_therapy' do
        valid_params[:opioid_therapy] = 'not a real status'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'must be one of 1, 2, 96, 97, 98'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Invalid Value'
      end

      it 'without opioid_therapy when primary_substance present' do
        valid_params[:opioid_therapy] = nil
        valid_params[:primary_substance] = '5'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'Must be filled when valid associated substance use is 5, 6 or 7'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Missing Value'
      end

      it 'with opioid_therapy of 96 when primary_substance present' do
        valid_params[:opioid_therapy] = '96'
        valid_params[:primary_substance] = '5'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'Cannot be 96 when substance use is 5, 6 or 7'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with opioid_therapy of 1 when primary_substance is not 5,6 or 7' do
        valid_params[:opioid_therapy] = '1'
        valid_params[:primary_substance] = '2'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'Substance use have to be one of 5,6 or 7 when the value is 1 or 2'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with opioid_therapy of 2 when secondary_substance is not 5,6 or 7' do
        valid_params[:opioid_therapy] = '2'
        valid_params[:secondary_substance] = '3'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'Substance use have to be one of 5,6 or 7 when the value is 1 or 2'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with opioid_therapy of 1 when tertiary_substance is not 5,6 or 7' do
        valid_params[:opioid_therapy] = '1'
        valid_params[:tertiary_substance] = '4'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).to have_key(:opioid_therapy)
        expect(result.errors.to_h[:opioid_therapy].first[:text]).to eq 'Substance use have to be one of 5,6 or 7 when the value is 1 or 2'
        expect(result.errors.to_h[:opioid_therapy].first[:category]).to eq 'Data Inconsistency'
      end

      it 'with opioid_therapy of 97 when tertiary_substance is not 5,6 or 7' do
        valid_params[:tertiary_substance] = '4'
        result = subject.call(valid_params)
        expect(result.failure?).to be_truthy
        expect(result.errors.to_h).not_to have_key(:opioid_therapy)
      end
    end
  end

  context 'Passed with valid required params' do
    it 'should see a success' do
      result = subject.call(valid_params)
      expect(result.success?).to be_truthy
    end
  end
end

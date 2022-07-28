# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/client_contract'

RSpec.describe ::Validators::Api::V1::ClientContract, dbclean: :after_each do
  let(:valid_params) do
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

  context 'Passed with invalid params return error' do
    it 'without client_id' do
      valid_params[:client_id] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:client_id)
      expect(result.errors.to_h[:client_id].first).to eq 'must be filled'
    end

    it 'without first name' do
      valid_params[:first_name] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:first_name)
      expect(result.errors.to_h[:first_name].first).to eq 'must be filled'
    end

    it 'First name more than 30 characters' do
      valid_params[:first_name] = 'testinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:first_name)
      expect(result.errors.to_h[:first_name].first).to eq 'Length cannot be more than 30 characters'
    end

    it 'without last name' do
      valid_params[:last_name] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:last_name)
      expect(result.errors.to_h[:last_name].first).to eq 'must be filled'
    end

    it 'Last name more than 30 characters' do
      valid_params[:last_name] = 'testinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:last_name)
      expect(result.errors.to_h[:last_name].first).to eq 'Length cannot be more than 30 characters'
    end

    it 'Middle name more than 30 characters' do
      valid_params[:middle_name] = 'testinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:middle_name)
      expect(result.errors.to_h[:middle_name].first).to eq 'Length cannot be more than 30 characters'
    end

    it 'alt_first_name more than 30 characters' do
      valid_params[:alt_first_name] = 'testinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:alt_first_name)
      expect(result.errors.to_h[:alt_first_name].first).to eq 'Length cannot be more than 30 characters'
    end

    it 'alt_last_name more than 30 characters' do
      valid_params[:alt_last_name] = 'testinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:alt_last_name)
      expect(result.errors.to_h[:alt_last_name].first).to eq 'Length cannot be more than 30 characters'
    end

    it 'ssn more than 9 characters' do
      valid_params[:ssn] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first).to eq 'Length should be 9 digits'
    end

    it 'medicaid_id more than 8 characters' do
      valid_params[:medicaid_id] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:medicaid_id)
      expect(result.errors.to_h[:medicaid_id].first).to eq 'Length cannot be more than 8 characters'
    end

    it 'without gender' do
      valid_params[:gender] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gender)
      expect(result.errors.to_h[:gender].first).to eq 'must be filled'
    end

    it 'Passing gender with more than 2 characters' do
      valid_params[:gender] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gender)
      expect(result.errors.to_h[:gender].first).to eq 'must be one of: 1, 2, 97, 98'
    end

    it 'without race' do
      valid_params[:race] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:race)
      expect(result.errors.to_h[:race].first).to eq 'must be filled'
    end

    it 'Passing race with more than 2 characters' do
      valid_params[:race] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:race)
      expect(result.errors.to_h[:race].first).to eq 'must be one of: 1, 2, 3, 4, 5, 13, 20, 21, 23, 97, 98'
    end

    it 'without ethnicity' do
      valid_params[:ethnicity] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ethnicity)
      expect(result.errors.to_h[:ethnicity].first).to eq 'must be filled'
    end

    it 'Passing ethnicity with more than 2 characters' do
      valid_params[:ethnicity] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ethnicity)
      expect(result.errors.to_h[:ethnicity].first).to eq 'must be one of: 1, 2, 3, 4, 5, 6, 97, 98'
    end

    it 'Passing sexual orientation with more than 2 characters' do
      valid_params[:sexual_orientation] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:sexual_orientation)
      expect(result.errors.to_h[:sexual_orientation].first).to eq 'must be one of: 1, 2, 3, 4, 95, 97, 98'
    end
  end

  context 'Passed with valid required params' do
    it 'should see a success' do
      result = subject.call(valid_params)
      expect(result.success?).to be_truthy
    end
  end
end

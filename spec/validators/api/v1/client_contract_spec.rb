# frozen_string_literal: true

require 'spec_helper'
require './app/domain/validators/api/v1/client_contract'

RSpec.describe ::Validators::Api::V1::ClientContract, dbclean: :around_each do
  let(:valid_params) do
    {
      client_id: '8347ehf',
      first_name: 'test',
      last_name: 'test',
      ssn: '223456789',
      medicaid_id: '72345678',
      dob: Date.today,
      gender: '1',
      sexual_orientation: '2',
      race: '3',
      ethnicity: '4',
      primary_language: '1',
      living_arrangement: '1',
      address_state: 'ME',
      address_city: 'Portland'
    }
  end

  context 'Passed with invalid params return error' do
    it 'without client_id' do
      valid_params[:client_id] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:client_id)
      expect(result.errors.to_h[:client_id].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:client_id].first[:category]).to eq 'Missing Value'
    end

    it 'without first name' do
      valid_params[:first_name] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:first_name)
      expect(result.errors.to_h[:first_name].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:first_name].first[:category]).to eq 'Missing Value'
    end

    it 'without last name' do
      valid_params[:last_name] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:last_name)
      expect(result.errors.to_h[:last_name].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:last_name].first[:category]).to eq 'Missing Value'
    end

    it 'suffix more than 18 characters' do
      valid_params[:suffix] = 'testinghsbdkabcakdsbdsidnakbciaksbdtestinghsbdkabcakdsbdsidnakbciaksbdasdfghjklpo'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:suffix)
      expect(result.errors.to_h[:suffix].first[:text]).to eq 'cannot contain more than 18 characters'
      expect(result.errors.to_h[:suffix].first[:category]).to eq 'Invalid Field Length'
    end

    it 'ssn more than 9 characters' do
      valid_params[:ssn] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Length must be 9 characters'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Field Length'
    end

    it 'ssn all the same digits' do
      valid_params[:ssn] = '111111111'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq('Cannot be all the same digits')
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn in sequential ascending order' do
      valid_params[:ssn] = '123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot be in sequential ascending order'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn in sequential descending order' do
      valid_params[:ssn] = '987654321'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot be in sequential descending order'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn starts with a 9' do
      valid_params[:ssn] = '997654321'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot end with 9, 666 or 000'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn ends with 0000' do
      valid_params[:ssn] = '217650000'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot end with 0000'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn starts with 666' do
      valid_params[:ssn] = '666650001'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot end with 9, 666 or 000'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn starts with 000' do
      valid_params[:ssn] = '000650001'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'Cannot end with 9, 666 or 000'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'ssn has 00 as the middle section' do
      valid_params[:ssn] = '123009999'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ssn)
      expect(result.errors.to_h[:ssn].first[:text]).to eq 'the 5th and 6th numbers from the right cannot be 00'
      expect(result.errors.to_h[:ssn].first[:category]).to eq 'Invalid Value'
    end

    it 'medicaid_id more than 8 characters' do
      valid_params[:medicaid_id] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:medicaid_id)
      expect(result.errors.to_h[:medicaid_id].first[:text]).to eq 'Length must be 8 characters'
      expect(result.errors.to_h[:medicaid_id].first[:category]).to eq 'Invalid Field Length'
    end

    it 'medicaid_id less than 8 characters' do
      valid_params[:medicaid_id] = '01234'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:medicaid_id)
      expect(result.errors.to_h[:medicaid_id].first[:text]).to eq 'Length must be 8 characters'
      expect(result.errors.to_h[:medicaid_id].first[:category]).to eq 'Invalid Field Length'
    end

    it 'medicaid_id is all 0s' do
      valid_params[:medicaid_id] = '00000000'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:medicaid_id)
      expect(result.errors.to_h[:medicaid_id].first[:text]).to eq 'cannot contain all 0s'
      expect(result.errors.to_h[:medicaid_id].first[:category]).to eq 'Invalid Value'
    end

    it 'medicaid_id does not start with 7' do
      valid_params[:medicaid_id] = '12345678'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:medicaid_id)
      expect(result.errors.to_h[:medicaid_id].first[:text]).to eq 'must start with 7'
      expect(result.errors.to_h[:medicaid_id].first[:category]).to eq 'Invalid Value'
    end

    it 'without gender' do
      valid_params[:gender] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gender)
      expect(result.errors.to_h[:gender].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:gender].first[:category]).to eq 'Missing Value'
    end

    it 'Passing gender with more than 2 characters' do
      valid_params[:gender] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:gender)
      expect(result.errors.to_h[:gender].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 6, 95, 97, 98'
      expect(result.errors.to_h[:gender].first[:category]).to eq 'Invalid Value'
    end

    it 'without race' do
      valid_params[:race] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:race)
      expect(result.errors.to_h[:race].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:race].first[:category]).to eq 'Missing Value'
    end

    it 'Passing race with more than 2 characters' do
      valid_params[:race] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:race)
      expect(result.errors.to_h[:race].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 13, 20, 21, 23, 97, 98'
      expect(result.errors.to_h[:race].first[:category]).to eq 'Invalid Value'
    end

    it 'without ethnicity' do
      valid_params[:ethnicity] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ethnicity)
      expect(result.errors.to_h[:ethnicity].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:ethnicity].first[:category]).to eq 'Missing Value'
    end

    it 'Passing ethnicity with more than 2 characters' do
      valid_params[:ethnicity] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:ethnicity)
      expect(result.errors.to_h[:ethnicity].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 6, 97, 98'
      expect(result.errors.to_h[:ethnicity].first[:category]).to eq 'Invalid Value'
    end

    it 'Passing sexual orientation with more than 2 characters' do
      valid_params[:sexual_orientation] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:sexual_orientation)
      expect(result.errors.to_h[:sexual_orientation].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 6, 95, 97, 98'
      expect(result.errors.to_h[:sexual_orientation].first[:category]).to eq 'Invalid Value'
    end

    it 'Passing living arrangement with more than 2 characters' do
      valid_params[:living_arrangement] = '488393'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:living_arrangement)
      expect(result.errors.to_h[:living_arrangement].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 97, 98'
      expect(result.errors.to_h[:living_arrangement].first[:category]).to eq 'Invalid Value'
    end

    it 'dob is more than 95 years ago' do
      valid_params[:dob] = (Date.today - 35_500).to_s
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:dob)
      expect(result.errors.to_h[:dob].first[:text]).to eq 'Verify age over 95'
    end

    it 'dob is greater than today' do
      valid_params[:dob] = (Date.today + 35).to_s
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:dob)
      expect(result.errors.to_h[:dob].first[:text]).to eq 'Cannot not be in the future'
    end

    it 'address line 1 has more than 50 characters' do
      valid_params[:address_line1] = 'testinghsbdkabcakdsbdsidnakbciaksbdtestinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line1)
      expect(result.errors.to_h[:address_line1].first[:text]).to eq 'cannot contain more than 50 characters'
      expect(result.errors.to_h[:address_line1].first[:category]).to eq 'Invalid Field Length'
    end

    it 'address line 1 contains special characters other than \' \' \' or -' do
      valid_params[:address_line1] = 'testinghs!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line1)
      expect(result.errors.to_h[:address_line1].first[:text]).to eq 'can only contain a hyphen (-), Apostrophe (‘), or a single space between characters'
      expect(result.errors.to_h[:address_line1].first[:category]).to eq 'Wrong Format'
    end

    it 'address_line1 contains 2 spaces in a row' do
      valid_params[:address_line1] = 'testinghs  dkfjhjfdhg'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line1)
      expect(result.errors.to_h[:address_line1].first[:text]).to eq 'can only contain a hyphen (-), Apostrophe (‘), or a single space between characters'
      expect(result.errors.to_h[:address_line1].first[:category]).to eq 'Wrong Format'
    end

    it 'address_line1 starts with a space' do
      valid_params[:address_line1] = ' testinghs dkfjhjfdhg'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line1)
      expect(result.errors.to_h[:address_line1].first[:text]).to eq 'can only contain a hyphen (-), Apostrophe (‘), or a single space between characters'
      expect(result.errors.to_h[:address_line1].first[:category]).to eq 'Wrong Format'
    end

    it 'address line 2 has more than 50 characters' do
      valid_params[:address_line2] = 'testinghsbdkabcakdsbdsidnakbciaksbdtestinghsbdkabcakdsbdsidnakbciaksbd'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line2)
      expect(result.errors.to_h[:address_line2].first[:text]).to eq 'cannot contain more than 50 characters'
      expect(result.errors.to_h[:address_line2].first[:category]).to eq 'Invalid Field Length'
    end

    it 'address line 2 contains special characters other than \' \' \' or -' do
      valid_params[:address_line2] = 'testinghs!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_line2)
      expect(result.errors.to_h[:address_line2].first[:text]).to eq 'can only contain a hyphen (-), Apostrophe (‘), or a single space between characters'
      expect(result.errors.to_h[:address_line2].first[:category]).to eq 'Wrong Format'
    end

    it 'phone1 contains non numeric characters' do
      valid_params[:phone1] = 'testinghs!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone1)
      expect(result.errors.to_h[:phone1].first[:text]).to eq 'must contain only numbers'
      expect(result.errors.to_h[:phone1].first[:category]).to eq 'Wrong Format'
    end

    it 'phone1 contains more than 10 characters' do
      valid_params[:phone1] = '1234567891011'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone1)
      expect(result.errors.to_h[:phone1].first[:text]).to eq 'must contain 10 characters'
      expect(result.errors.to_h[:phone1].first[:category]).to eq 'Invalid Field Length'
    end

    it 'phone1 starts with 0' do
      valid_params[:phone1] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone1)
      expect(result.errors.to_h[:phone1].first[:text]).to eq 'cannot start with 0'
      expect(result.errors.to_h[:phone1].first[:category]).to eq 'Invalid Value'
    end

    it 'phone2 contains non numeric characters' do
      valid_params[:phone2] = 'testinghs!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone2)
      expect(result.errors.to_h[:phone2].first[:text]).to eq 'must contain only numbers'
      expect(result.errors.to_h[:phone2].first[:category]).to eq 'Wrong Format'
    end

    it 'phone2 contains more than 10 characters' do
      valid_params[:phone2] = '1234567891011'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone2)
      expect(result.errors.to_h[:phone2].first[:text]).to eq 'must contain 10 characters'
      expect(result.errors.to_h[:phone2].first[:category]).to eq 'Invalid Field Length'
    end

    it 'phone2 starts with 0' do
      valid_params[:phone2] = '0123456789'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:phone2)
      expect(result.errors.to_h[:phone2].first[:text]).to eq 'cannot start with 0'
      expect(result.errors.to_h[:phone2].first[:category]).to eq 'Invalid Value'
    end

    it 'address_zip_code is not 5 or 10' do
      valid_params[:address_zip_code] = '123456'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_zip_code)
      expect(result.errors.to_h[:address_zip_code].first[:text]).to eq 'must contain 5 or 10 characters'
      expect(result.errors.to_h[:address_zip_code].first[:category]).to eq 'Invalid Field Length'
    end

    it 'address_zip_code starts with 00' do
      valid_params[:address_zip_code] = '00345'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_zip_code)
      expect(result.errors.to_h[:address_zip_code].first[:text]).to eq 'cannot start with 00'
      expect(result.errors.to_h[:address_zip_code].first[:category]).to eq 'Invalid Value'
    end

    it 'address_zip_code doesnt match zip patter' do
      valid_params[:address_zip_code] = '1034512345'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_zip_code)
      expect(result.errors.to_h[:address_zip_code].first[:text]).to eq 'must be either 5 or 10 numeric characters, including a hyphen (-) and a leading zero (e.g., 20002 or 01701-3320)'
      expect(result.errors.to_h[:address_zip_code].first[:category]).to eq 'Invalid Value'
    end

    it 'without address_state' do
      valid_params[:address_state] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_state)
      expect(result.errors.to_h[:address_state].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:address_state].first[:category]).to eq 'Missing Value'
    end

    it 'Passing address_state with invalid value' do
      valid_params[:address_state] = 'invalid!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_state)
      expect(result.errors.to_h[:address_state].first[:text]).to eq 'must be a valid 2 letter state abbreviation'
      expect(result.errors.to_h[:address_state].first[:category]).to eq 'Invalid Value'
    end

    it 'without address_city' do
      valid_params[:address_city] = nil
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_city)
      expect(result.errors.to_h[:address_city].first[:text]).to eq 'Must be filled'
      expect(result.errors.to_h[:address_city].first[:category]).to eq 'Missing Value'
    end

    it 'with invalid characters in address_city' do
      valid_params[:address_city] = 'P0rtland!'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_city)
      expect(result.errors.to_h[:address_city].first[:text]).to eq 'City can only contain a hyphen (-), Apostrophe (‘), or a single space between characters'
      expect(result.errors.to_h[:address_city].first[:category]).to eq 'Wrong Format'
    end

    it 'with invalid address_ward' do
      valid_params[:address_ward] = 'invalid'
      result = subject.call(valid_params)
      expect(result.failure?).to be_truthy
      expect(result.errors.to_h).to have_key(:address_ward)
      expect(result.errors.to_h[:address_ward].first[:text]).to eq 'must be one of 1, 2, 3, 4, 5, 6, 7, 8, 96, 97, 98'
      expect(result.errors.to_h[:address_ward].first[:category]).to eq 'Invalid Value'
    end
  end

  context 'Passed with valid required params' do
    it 'should see a success' do
      result = subject.call(valid_params)
      expect(result.success?).to be_truthy
    end
  end
end

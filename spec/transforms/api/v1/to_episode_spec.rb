# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ::Transforms::Api::V1::ToEpisode, dbclean: :after_each do
  include Dry::Monads[:result, :do]

  let(:record) { FactoryBot.build(:record) }

  context 'with a valid row' do
    before do
      @result = described_class.new.call(record)
      @record = @result.value!
    end
    it 'should be a success' do
      expect(@result).to be_success
    end
    it 'should convert dates to dates' do
      expect(@record[:last_contact_date].class).to eq Date
    end
    it 'should covert integers to strings' do
      expect(@record[:treatment_type].class).to eq String
    end
    it 'should have a client hash' do
      expect(@record).to have_key(:client)
      expect(@record[:client].class).to eq Hash
    end
    it 'should have a client profile' do
      expect(@record).to have_key(:client_profile)
      expect(@record[:client_profile].class).to eq Hash
    end
    it 'should not have dob on the top level' do
      expect(@record).to_not have_key(:dob)
    end
  end
  context 'date coversion' do
    it 'should not convert invalid dates to dates' do
      record.payload[:last_contact_date] = '2387647677'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should not convert dates that do not match pattern' do
      record.payload[:last_contact_date] = '12-02-2022'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should not convert dates that have a month outside of expected range 1-12 for - dates' do
      record.payload[:last_contact_date] = '2022-13-12'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should not convert dates that have a month outside of expected range 1-12 for / dates' do
      record.payload[:last_contact_date] = '14/11/2022'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should not convert dates that have a day outside of expected range 1-31 for - dates' do
      record.payload[:last_contact_date] = '2022-12-32'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should not convert dates that have a day outside of expected range 1-31 for / dates' do
      record.payload[:last_contact_date] = '10/34/2022'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to_not eq Date
    end
    it 'should convert dates that match pattern YYYY-MM-DD' do
      record.payload[:last_contact_date] = '2022-12-10'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to eq Date
    end
    it 'should convert dates that match pattern YYYY-M-D' do
      record.payload[:last_contact_date] = '2022-2-1'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to eq Date
    end
    it 'should convert dates that match pattern D/M/YYYY' do
      record.payload[:last_contact_date] = '2/1/2022'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to eq Date
    end
    it 'should convert dates that match pattern DD/MM/YYYY' do
      record.payload[:last_contact_date] = '12/01/2022'
      result = described_class.new.call(record).value!
      expect(result[:last_contact_date].class).to eq Date
    end
  end
end

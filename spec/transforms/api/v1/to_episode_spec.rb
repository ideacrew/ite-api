# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ::Transforms::Api::V1::ToEpisode, dbclean: :after_each do
  include Dry::Monads[:result, :do]

  let(:extract) { FactoryBot.create(:extract, :with_transactions) }

  let(:transaction) { extract.transactions.first }

  context 'with a valid row' do
    before do
      @result = described_class.new.call(transaction)
      @transaction = @result.value!
    end
    it 'should be a success' do
      expect(@result).to be_success
    end
    it 'should convert dates to dates' do
      expect(@transaction[:admission_date].class).to eq Date
    end
    it 'should covert integers to strings' do
      expect(@transaction[:treatment_type].class).to eq String
    end
    it 'should have a client hash' do
      expect(@transaction).to have_key(:client)
      expect(@transaction[:client].class).to eq Hash
    end
    it 'should have a client profile' do
      expect(@transaction).to have_key(:client_profile)
      expect(@transaction[:client_profile].class).to eq Hash
    end
    it 'should not have dob on the top level' do
      expect(@transaction).to_not have_key(:dob)
    end
  end
end

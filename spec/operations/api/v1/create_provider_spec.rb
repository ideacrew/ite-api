# frozen_string_literal: true

require 'rails_helper'

describe ::Operations::Api::V1::CreateProvider, dbclean: :after_each do
  include Dry::Monads[:result, :do]

  let(:params) do
    {
      provider_name: 'Acme Studio',
      provider_nick_name: 'Acme',
      npi: '0102030405',
      is_active: true,
      mh: true,
      sud: false,
      adult_care: true,
      child_care: false,
      office_locations:
    }
  end

  let(:office_locations) do
    [{
      is_primary: true,
      address:,
      phones:,
      emails:
    }]
  end

  let(:address) do
    {
      address_line1: 'Address line 1',
      city: 'Washington',
      state: 'dc',
      zip: '12345'
    }
  end

  let(:emails) do
    [{
      address: 'test@test.com'
    }]
  end

  let(:phones) do
    [{
      area_code: '101',
      number: '1234567',
      extension: '111'
    }]
  end

  context 'valid params' do
    before do
      @result = described_class.new.call(params)
      @provider = @result.value!
    end
    it 'should be a success' do
      expect(@result).to be_success
    end
    it 'should create provider' do
      expect(@provider).to be_a(::Api::V1::Provider)
    end
    it 'extract should have a provider gateway identifier' do
      expect(@provider.provider_gateway_identifier).to_not be_nil
      expect(@provider.provider_gateway_identifier.length).to eq 3
    end
  end

  context 'invalid params' do
    context 'invalid extract' do
      before do
        params[:provider_name] = nil
      end
      it 'should be a failure' do
        expect(described_class.new.call(params)).to be_failure
      end
      it 'should not create a provider' do
        expect(described_class.new.call(params).failure).to_not be_a(::Api::V1::Provider)
      end
    end
  end
end

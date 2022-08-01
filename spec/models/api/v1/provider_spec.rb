# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Provider, type: :model, dbclean: :after_each do
  let(:office_location) { FactoryBot.build(:office_location, :with_phones, :with_emails) }

  let(:provider_params) do
    { provider_name: 'Provider',
      npi: '0123456789',
      is_active: true,
      mh: true,
      sud: true,
      adult_care: true,
      child_care: true,
      office_locations: [office_location] }
  end

  context 'with a valid params' do
    context 'all values filled in' do
      before do
        @provider = described_class.create(provider_params)
      end

      it 'will create an provider' do
        expect(@provider.persisted?).to eq true
        expect(@provider.class).to eq(described_class)
      end

      it 'will create an provider with provider gateway id of length 3' do
        expect(@provider.provider_gateway_identifier).not_to eq nil
        expect(@provider.provider_gateway_identifier.length).to eq 3
      end
    end
  end

  context 'with a invalid params' do
    context 'will not create an provider' do
      it 'without a provider name' do
        provider_params[:provider_name] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a npi' do
        provider_params[:npi] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'npi length less than 10' do
        provider_params[:npi] = '12345'
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'npi length more than 10' do
        provider_params[:npi] = '12345428382984893'
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'npi is not numeric' do
        provider_params[:npi] = 'sbdyekansu'
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a is_active' do
        provider_params[:is_active] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a mh' do
        provider_params[:mh] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a sud' do
        provider_params[:sud] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a adult_care' do
        provider_params[:adult_care] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a child_care' do
        provider_params[:child_care] = nil
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end

      it 'without a office_locations' do
        provider_params[:office_locations] = []
        provider = described_class.new(provider_params)
        expect(provider.save).to eq false
      end
    end
  end
end

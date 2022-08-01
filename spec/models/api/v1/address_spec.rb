# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Address, type: :model, dbclean: :after_each do
  let(:office_location) { Api::V1::OfficeLocation.new }
  let(:address) { FactoryBot.build(:address, office_location:) }

  context 'with a valid address' do
    context 'all values filled in' do
      it 'will create an address object' do
        expect(address.save).to eq true
        expect(address.class).to eq(described_class)
      end
    end
  end

  context 'with a invalid params' do
    let(:address_params) do
      {
        office_location:,
        address_line1: 'Address line 1',
        city: 'Washington',
        state: 'dc',
        zip: '12345'
      }
    end

    context 'will not create an address object' do
      it 'without a office_location' do
        address_params[:address_line1] = nil
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end

      it 'without a office_location' do
        address_params[:city] = nil
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end

      it 'without a office_location' do
        address_params[:state] = nil
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end

      it 'without a office_location' do
        address_params[:zip] = nil
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end

      it 'invalid zip' do
        address_params[:zip] = '72383093923'
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end

      it 'zip not numeric' do
        address_params[:zip] = 'ashdb'
        address = described_class.new(address_params)
        expect(address.save).to eq false
      end
    end
  end
end

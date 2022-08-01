# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Phone, type: :model, dbclean: :after_each do
  let(:office_location) { Api::V1::OfficeLocation.new }
  let(:phone) { FactoryBot.build(:phone, office_location:) }

  context 'with a valid number' do
    context 'all values filled in' do
      it 'will create an phone object' do
        expect(phone.save).to eq true
        expect(phone.class).to eq(described_class)
      end

      it 'will create an phone object with full phone number' do
        expect(phone.save).to eq true
        expect(phone.full_phone_number).not_to eq nil
      end
    end
  end

  context 'with a invalid params' do
    let(:phone_params) do
      { area_code: '123',
        number: '4567890' }
    end

    context 'will not create an phone object' do
      it 'without area_code' do
        phone_params[:area_code] = nil
        phone = described_class.new(phone_params)
        expect(phone.save).to eq false
      end

      it 'invalid area code' do
        phone_params[:area_code] = '472983'
        phone = described_class.new(phone_params)
        expect(phone.save).to eq false
      end

      it 'without number' do
        phone_params[:number] = nil
        phone = described_class.new(phone_params)
        expect(phone.save).to eq false
      end

      it 'invalid number' do
        phone_params[:area_code] = '472372923893983'
        phone = described_class.new(phone_params)
        expect(phone.save).to eq false
      end
    end
  end
end

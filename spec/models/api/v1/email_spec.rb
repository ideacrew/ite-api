# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Email, type: :model, dbclean: :around_each do
  let(:office_location) { Api::V1::OfficeLocation.new }
  let(:email) { FactoryBot.build(:email, office_location:) }

  context 'with a valid address' do
    context 'all values filled in' do
      it 'will create an address object' do
        expect(email.save).to eq true
        expect(email.class).to eq(described_class)
      end
    end
  end

  context 'with a invalid params' do
    let(:email_params) do
      { address: 'test' }
    end

    context 'will not create an email object' do
      it 'without a address' do
        email_params[:address] = nil
        email = described_class.new(email_params)
        expect(email.save).to eq false
      end

      it 'invalid a address' do
        email_params[:address] = 'test@test'
        email = described_class.new(email_params)
        expect(email.save).to eq false
      end

      it 'address as string' do
        email = described_class.new(email_params)
        expect(email.save).to eq false
      end
    end
  end
end

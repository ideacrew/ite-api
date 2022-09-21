# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Provider, type: :model, dbclean: :around_each do
  let(:office_location) { FactoryBot.build(:office_location, :with_phones, :with_emails) }

  let(:provider_params) do
    { provider_name: 'Provider',
      npi: '0123456789',
      is_active: true,
      mh: true,
      sud: true,
      adult_care: true,
      child_care: true,
      office_locations: [office_location], extracts: [] }
  end

  let(:extract_params) do
    {
      provider_gateway_identifier: 1,
      coverage_start: Date.today - 100,
      coverage_end: Date.today - 80,
      extracted_on: Date.today - 80
    }
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

      it 'with an existing provider_gateway_identifier' do
        existing_provider = FactoryBot.create(:provider)
        provider_params[:provider_gateway_identifier] = existing_provider.provider_gateway_identifier
        new_provider = described_class.new(provider_params)
        new_provider.save
        expect(new_provider.provider_gateway_identifier).not_to eq(existing_provider.provider_gateway_identifier)
      end
    end
  end

  context 'with a submission status' do
    before do
      @provider = described_class.create(provider_params)
      extract_params[:provider_gateway_identifier] = @provider.provider_gateway_identifier
      allow(Date).to receive(:today).and_return(Date.new(Date.today.year, Date.today.month, 11))
    end

    it 'will have a status of Overdue if no extracts' do
      expect(@provider.submission_status(nil, Date.today)).to eq 'Past Due'
    end

    it 'will have a status of Expecting Submission if no extracts' do
      year = (Date.today - 1.month).month > 0 ? Date.today.year : (Date.today.year - 1)
      allow(Date).to receive(:today).and_return(Date.new(Date.today.year, Date.today.month, 9))
      expect(@provider.submission_status(nil, Date.new(year, (Date.today - 1.month).month, 9))).to eq 'Expecting Submission'
    end

    it 'will have a status of Need Resubmission if no valid extracts in the given period' do
      extract_params[:coverage_end] = Date.today
      extract_params[:status] = 'Invalid'
      @provider.extracts.build(extract_params)
      @provider.save
      expect(@provider.submission_status(@provider.extracts.last, Date.today)).to eq 'Need Resubmission'
    end

    it 'will have a status of Current if valid extract where the coverage is in the given period' do
      extract_params[:coverage_end] = Date.today
      extract_params[:status] = 'Valid'
      @provider.extracts.build(extract_params)
      @provider.save
      expect(@provider.submission_status(@provider.extracts.last, Date.today)).to eq 'Current'
    end

    after do
      allow(Date).to receive(:today).and_return(Date.today)
    end
  end

  context 'reporting_period_extracts' do
    before do
      @provider = described_class.create(provider_params)
      extract_params[:provider_gateway_identifier] = @provider.provider_gateway_identifier
    end

    it 'will return an extract when coverage end is in the period' do
      extract_params[:coverage_end] = Date.today
      extract_params[:status] = 'Valid'
      @provider.extracts.build(extract_params)
      @provider.save
      expect(@provider.reporting_period_extracts(Date.today).count).to eq 1
    end

    it 'will not return an extract when coverage end is in the month of period' do
      extract_params[:coverage_end] = Date.today.next_month
      extract_params[:status] = 'Valid'
      @provider.extracts.build(extract_params)
      @provider.save
      expect(@provider.reporting_period_extracts(Date.today).count).to eq 0
    end

    it 'will not return an extract when coverage end is in the prev month of period' do
      extract_params[:coverage_end] = Date.today.prev_month
      extract_params[:status] = 'Valid'
      @provider.extracts.build(extract_params)
      @provider.save
      expect(@provider.reporting_period_extracts(Date.today).count).to eq 0
    end
  end
end

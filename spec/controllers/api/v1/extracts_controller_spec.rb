# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ExtractsController, dbclean: :around_each do
  let(:user) { User.create(email: 'test@user.com', password: 'Test1234*', password_confirmation: 'Test1234*') }
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
  let(:provider) { Api::V1::Provider.create(provider_params) }

  let(:extract_params) do
    {
      provider_gateway_identifier: provider.provider_gateway_identifier,
      coverage_start: '2022-07-01',
      coverage_end: '2022-07-31',
      extracted_on: '2022-07-31',
      file_name: 'extract_data',
      file_type: 'Initial',
      records: [
        {
          record_type: '',
          provider_id: 15,
          episode_id: 194_062,
          num_of_prior_episodes: 1,
          admission_date: '7-31-2022',
          last_contact_date: '31/02/2022',
          first_name: 'Test',
          last_name: 'One',
          treatment_type: 1,
          client_id: '',
          collateral: 2,
          dob: '05/11/1992',
          gender: 2,
          race: 1,
          ethnicity: 5,
          primary_language: 1,
          num_of_prior_admissions: 96,
          arrests_past_30days: 0,
          education: 12,
          employment: 4
        }
      ]
    }
  end

  before :each do
    @extract = ::Operations::Api::V1::IngestExtract.new.call(extract_params.to_h).value!
  end

  context 'GET Index' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).not_to eq ''
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :index }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).not_to eq ''
    end
  end

  context 'POST Create' do
    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      post :ingest, params: extract_params
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider with invalid params' do
      extract_params[:extracted_on] = nil
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      post :ingest, params: extract_params
      expect(JSON.parse(response.body)['status_text']).to eq 'Could not ingest payload'
    end

    it 'When user is not dbh' do
      sign_in user
      expect { post :ingest, params: extract_params }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      expect { post :ingest, params: extract_params }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'GET show' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      get :show, params: { id: @extract.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      get :show, params: { id: @extract.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider without provider id' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: nil)
      sign_in user
      get :show, params: { id: @extract.id }
      expect(JSON.parse(response.body)['status_text']).to eq 'Could not find extract'
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :show, params: { id: @extract.id } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'GET download_failing_records' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      expect { get :failing_records, params: { id: @extract.id } }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      get :failing_records, params: { id: @extract.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider without provider id' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: nil)
      sign_in user
      get :failing_records, params: { id: @extract.id }
      expect(JSON.parse(response.body)['status_text']).to eq 'Could not find extract'
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :failing_records, params: { id: @extract.id } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'GET failing_data_fields' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      expect { get :failing_data_fields, params: { id: @extract.id } }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: provider.id)
      sign_in user
      get :failing_data_fields, params: { id: @extract.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider without provider id' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: provider.provider_gateway_identifier, provider_id: nil)
      sign_in user
      get :failing_data_fields, params: { id: @extract.id }
      expect(JSON.parse(response.body)['status_text']).to eq 'Could not find extract'
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :failing_data_fields, params: { id: @extract.id } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end

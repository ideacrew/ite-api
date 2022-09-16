# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProvidersController, dbclean: :around_each do
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

  before :each do
    @provider = Api::V1::Provider.create(provider_params)
  end

  context 'GET Index' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).not_to eq ''
    end

    it 'When user is not dbh' do
      sign_in user
      expect { get :index }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: @provider.provider_gateway_identifier, provider_id: @provider.id)
      sign_in user
      expect { get :index }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'POST Create' do
    let(:office_location_params) do
      provider_params[:office_locations].first.attributes
    end

    let(:new_provider_params) do
      { provider_name: 'Provider',
        npi: '0123456789',
        is_active: true,
        mh: true,
        sud: true,
        adult_care: true,
        child_care: true,
        office_locations: [office_location_params], extracts: [] }
    end

    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      post :create, params: new_provider_params
      expect(response).to have_http_status(:success)
    end

    it 'When user is dbh' do
      new_provider_params[:provider_name] = nil
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      post :create, params: new_provider_params
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['status_text']).to eq 'Could not create provider'
    end

    it 'When user is not dbh' do
      sign_in user
      expect { post :create, params: new_provider_params }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: @provider.provider_gateway_identifier, provider_id: @provider.id)
      sign_in user
      expect { post :create, params: new_provider_params }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'GET show' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      get :show, params: { id: @provider.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: @provider.provider_gateway_identifier, provider_id: @provider.id)
      sign_in user
      get :show, params: { id: @provider.id }
      expect(response).to have_http_status(:success)
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :show, params: { id: @provider.id } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'GET submission_summary' do
    it 'When user is dbh' do
      DbhStaffRole.create(is_active: true, user:)
      sign_in user
      get :submission_summary, params: { year: @provider.created_at.year, month: @provider.created_at.month }
      expect(response).to have_http_status(:success)
    end

    it 'When user is provider' do
      ProviderStaffRole.create(is_active: true, user:, provider_gateway_identifier: @provider.provider_gateway_identifier, provider_id: @provider.id)
      sign_in user
      get :submission_summary, params: { year: @provider.created_at.year, month: @provider.created_at.month }
      expect(response).to have_http_status(:success)
    end

    it 'When user is not authorized' do
      sign_in user
      expect { get :submission_summary, params: { year: @provider.created_at.year, month: @provider.created_at.month } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end

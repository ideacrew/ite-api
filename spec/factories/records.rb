# frozen_string_literal: true

FactoryBot.define do
  factory :record, class: '::Api::V1::Record' do
    extract

    payload do
      { provider_id: '15',
        episode_id: '194062',
        admission_date: '01/04/2022',
        treatment_type: '4',
        client_id: 'LEVN46410511921',
        codependent: '2',
        dob: '05/11/4002',
        gender: '2',
        race: nil,
        ethnicity: '9',
        primary_language: '-1',
        num_of_prior_admissions: '2',
        arrests_past_30days: nil,
        education: '12',
        employment: '3',
        last_contact_date: '05/11/4002' }
    end
  end
end

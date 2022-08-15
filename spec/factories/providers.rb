# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: '::Api::V1::Provider' do
    provider_name { 'Dr. Strangelove' }
    provider_nick_name { 'Strange' }
    npi { 1_234_567_890 }
    provider_gateway_identifier { 412 }
    is_active { true }
    mh { true }
    sud { true }
    adult_care { true }
    child_care { true }
    office_locations { [FactoryBot.build(:office_location, :with_phones, :with_emails)] }

    trait :with_extracts do
      extracts do
        [FactoryBot.build(:extract)]
      end
    end
  end
end

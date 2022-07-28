# frozen_string_literal: true

FactoryBot.define do
  factory :extract, class: '::Api::V1::Extract' do
    provider_gateway_identifier { '13' }
    coverage_start { Date.today.to_s }
    coverage_end { Date.today.to_s }
    extracted_on { Date.today.to_s }
    file_type { 'Initial' }
    record_group { 'admission' }

    trait :with_records do
      records do
        [FactoryBot.build(:record)]
      end
    end
  end
end

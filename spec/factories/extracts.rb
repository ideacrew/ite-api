# frozen_string_literal: true

FactoryBot.define do
  factory :extract, class: '::Api::V1::Extract' do
    provider_gateway_identifier { '13' }
    coverage_start { Date.today }
    coverage_end { Date.today }
    extracted_on { Date.today }
    file_type { 'Initial' }
    transaction_group { 'admission' }
  end
end

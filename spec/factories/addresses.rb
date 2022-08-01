# frozen_string_literal: true

FactoryBot.define do
  factory :address, class: '::Api::V1::Address' do
    address_line1 { 'Address line 1' }
    city { 'Washington' }
    state { 'dc' }
    zip { '12345' }
  end
end

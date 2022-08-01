# frozen_string_literal: true

FactoryBot.define do
  factory :email, class: '::Api::V1::Email' do
    address { 'test@test.com' }

    trait :invalid_address do
      address { 'test.com ' }
    end
  end
end

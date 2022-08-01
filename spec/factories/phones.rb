# frozen_string_literal: true

FactoryBot.define do
  factory :phone, class: '::Api::V1::Phone' do
    area_code { '101' }
    number { '1234567' }
    extension { '111' }

    trait :without_kind do
      kind { ' ' }
    end

    trait :without_area_code do
      area_code { ' ' }
    end

    trait :without_number do
      number { ' ' }
    end
  end
end

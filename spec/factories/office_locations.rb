# frozen_string_literal: true

FactoryBot.define do
  factory :office_location, class: '::Api::V1::OfficeLocation' do
    address { FactoryBot.build(:address) }

    trait :with_phones do
      phones do
        [FactoryBot.build(:phone)]
      end
    end

    trait :with_emails do
      emails do
        [FactoryBot.build(:email)]
      end
    end
  end
end

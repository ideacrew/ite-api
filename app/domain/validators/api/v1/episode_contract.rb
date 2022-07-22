# frozen_string_literal: true

require './app/models/types'

module Validators
  module Api
    module V1
      # Contract for Episode.
      class EpisodeContract < Dry::Validation::Contract
        params do
          required(:episode_id).filled(:string)
          optional(:codepedent).maybe(:string)
          optional(:admission_type).maybe(:date)
          optional(:admission_date).maybe(:date)
          optional(:treatment_type).maybe(:string)
          optional(:service_request_date).maybe(:date)
          optional(:discharge_date).maybe(:date)
          optional(:discharge_type).maybe(:string)
          optional(:discharge_reason).maybe(:string)
          optional(:last_contact_date).maybe(:date)
          optional(:num_of_prior_episodes).maybe(:string)
          optional(:referral_source).maybe(:string)
          optional(:criminal_justice_referral).maybe(:string)
          optional(:primary_payment_source).maybe(:string)
          optional(:client).maybe(:hash)
          optional(:client_profile).maybe(:hash)
          optional(:clinical_info).maybe(:hash)
        end
      end
    end
  end
end

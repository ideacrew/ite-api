# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extend Dry Types
module Types
  include Dry.Types
  include Dry::Logic

  RecordGroups = Types::String.enum('admission', 'discharge', 'active').freeze
  CODEPEDENT_OPTIONS = Types::String.enum('1', '2').freeze
  RECORD_TYPE_OPTIONS = Types::String.enum('A', 'T', 'D', 'M', 'X', 'E').freeze
  TREATMENT_TYPE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '72', '73', '74', '75', '76', '77',
                                              '96').freeze
  DISCHARGE_REASON_OPTIONS = Types::String.enum('1', '2', '3', '4', '14', '24', '5', '6', '7', '34', '35', '36', '37', '95', '96',
                                                '97', '98').freeze
  GENDER_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '95', '97', '98').freeze
  SEXUAL_ORIENTATION_OPTIONS = Types::String.enum('1', '2', '3', '4', '95', '97', '98').freeze
  RACE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '13', '20', '21', '23', '97', '98').freeze
  ETHNICITY_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '97', '98').freeze
  LANGUAGE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '97',
                                        '98').freeze
  REFERRAL_SOURCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '97', '98').freeze
  PAYMENT_SOURCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '96', '97',
                                              '98').freeze
  LIVING_ARRANGEMENT_OPTIONS = Types::String.enum('1', '3', '11', '12', '13', '14', '15', '16', '17', '97',
                                                  '98').freeze
  EDUCATION_OPTIONS = Types::String.enum('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14',
                                         '15', '16', '17', '18', '71', '72', '73', '74', '97', '98').freeze
  EMPLOYMENT_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '97', '98').freeze
  LEGAL_STATUS_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '96', '97', '98').freeze
  ROUTE_OF_ADMINISTRATION_OPTIONS = Types::String.enum('1', '2', '3', '4', '20', '96', '97', '98').freeze
  PRIOR_SU_EPISODE_OPTIONS = Types::String.enum('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '97', '98').freeze
  CRIMINAL_JUSTICE_REFERRAL_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '96', '97', '98').freeze
end

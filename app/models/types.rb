# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extend Dry Types
module Types
  include Dry.Types
  include Dry::Logic

  CODEPEDENT_OPTIONS = Types::String.enum('1', '2').freeze
  RECORD_TYPE_OPTIONS = Types::String.enum('A', 'T', 'M', 'X').freeze
  TREATMENT_TYPE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '72', '73', '74', '75', '76', '77',
                                              '96').freeze
  DISCHARGE_REASON_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '95',
                                                '97', '98').freeze
  GENDER_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '95', '97', '98').freeze
  SEXUAL_ORIENTATION_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '95', '97', '98').freeze
  RACE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '13', '20', '21', '23', '97', '98').freeze
  ETHNICITY_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '97', '98').freeze
  LANGUAGE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '95', '97',
                                        '98').freeze
  REFERRAL_SOURCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '97', '98').freeze
  PAYMENT_SOURCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '97',
                                              '98').freeze
  LIVING_ARRANGEMENT_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '97',
                                                  '98').freeze
  EDUCATION_OPTIONS = Types::String.enum('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14',
                                         '15', '16', '17', '18', '71', '72', '73', '74', '97', '98').freeze
  EMPLOYMENT_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '97', '98').freeze
  LEGAL_STATUS_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '96', '97', '98').freeze
  ROUTE_OF_ADMINISTRATION_OPTIONS = Types::String.enum('1', '2', '3', '4', '20', '96', '97', '98').freeze
  PRIOR_SU_EPISODE_OPTIONS = Types::String.enum('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '97', '98').freeze
  CRIMINAL_JUSTICE_REFERRAL_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '96', '97', '98').freeze
  MARITAL_STATUS_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '97', '98').freeze
  VETERAN_STATUS_OPTIONS = Types::String.enum('1', '2', '97', '98').freeze
  PREGNANCY_OPTIONS = Types::String.enum('1', '2', '96', '97', '98').freeze
  SCHOOL_ATTENDENCE_OPTIONS = Types::String.enum('1', '2', '96', '97', '98').freeze
  HEALTH_INSURANCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '97', '98').freeze
  SELF_HELP_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '96', '97', '98').freeze
  INCOME_SOURCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '95', '96', '97', '98').freeze
  NOT_IN_LABOR_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '96', '97', '98').freeze
  WARD_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '96', '97', '98').freeze
  ARREST_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14',
                                      '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '97', '98').freeze
  SME_OPTIONS = Types::String.enum('1', '2', '3', '4', '97', '98').freeze
  COOCCURRING_OPTIONS = Types::String.enum('1', '2', '97', '98').freeze
  GAF_OPTIONS = Types::String.enum(((1..100).map(&:to_s) << '997' << '998').flatten).freeze
  UsStateAbbreviationKind =
    Types::String.enum(
      'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FM', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA',
      'ME', 'MH', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW',
      'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VI', 'VA', 'WA', 'WV', 'WI', 'WY'
    ).freeze
  SUBSTANCE_OPTIONS = Types::String.enum('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '20', '96',
                                         '97', '98').freeze
  SU_FREQUENCY_ADMISSION = Types::String.enum('1', '2', '3', '4', '5', '96', '97', '98').freeze
  SU_ROUTE_OPTIONS = Types::String.enum('1', '2', '3', '4', '20', '96', '97', '98').freeze
  AGE_OPTIONS = Types::String.enum((1..98).map(&:to_s).flatten).freeze
  OPIOD_THERAPY_OPTIONS = Types::String.enum('1', '2', '96', '97', '98').freeze
end

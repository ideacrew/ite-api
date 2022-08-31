# frozen_string_literal: true

# user.rb

class User
  include Mongoid::Document
  include RailsJwtAuth::Authenticatable
  include RailsJwtAuth::Recoverable
  include RailsJwtAuth::Trackable

  field :email, type: String
  field :roles, type: Array

  validates :email, presence: true,
                    uniqueness: true,
                    format: URI::MailTo::EMAIL_REGEXP
end

# frozen_string_literal: true

# User model
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include RailsJwtAuth::Authenticatable
  include RailsJwtAuth::Recoverable
  include RailsJwtAuth::Trackable

  field :email, type: String

  embeds_one :provider_staff_role, class_name: 'ProviderStaffRole', cascade_callbacks: true
  embeds_one :dbh_staff_role, class_name: 'DbhStaffRole', cascade_callbacks: true

  validates :email, presence: true,
                    uniqueness: true,
                    format: URI::MailTo::EMAIL_REGEXP

  validate :password_custom_rules

  def to_token_payload(_request = nil)
    if RailsJwtAuth.simultaneous_sessions.positive?
      auth_tokens&.last ? { auth_token: auth_tokens.last, dbh_user: dbh_user?, provider: provider?, provider_gateway_identifier:, provider_id:, email:, provider_name: } : false
    else
      { id: id.to_s }
    end
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def update_password(params)
    current_password_error = if (current_password = params.delete(:current_password)).blank?
                               'blank'
                             elsif !authenticate(current_password)
                               'invalid'
                             end

    # if recoberable module is enabled ensure clean recovery to allow save
    self.reset_password_token = self.reset_password_sent_at = nil if respond_to? :reset_password_token

    # close all sessions or other sessions when pass current_auth_token
    current_auth_token = params.delete :current_auth_token
    self.auth_tokens = current_auth_token ? [current_auth_token] : []

    assign_attributes(params)
    valid? # validates first other fields
    errors.add(:current_password, current_password_error) if current_password_error
    errors.add(:password, 'blank') if params[:password].blank?

    return false unless errors.empty?
    return false unless save

    true
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def dbh_user?
    return false unless dbh_staff_role

    dbh_staff_role.active?.present?
  end

  def provider?
    return false unless provider_staff_role

    provider_staff_role.active?.present?
  end

  def provider_gateway_identifier
    return unless provider?

    provider_staff_role&.provider_gateway_identifier
  end

  def provider_id
    return unless provider?

    provider_staff_role&.provider_id&.to_s
  end

  def provider_name
    return unless provider?

    provider_staff_role&.provider_name&.to_s
  end

  def password_custom_rules
    if password.present? && (password.length < 8)
      errors.add :password, 'Password must be at least 8 characters'
    elsif password.present? && !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d ]).+$/)
      errors.add :password, 'Your password must include at least 1 lowercase letter, 1 uppercase letter, 1 number, and 1 character that’s not a number, letter, or space.'
    elsif password.present? && password.match(/#{::Regexp.escape(email)}/i)
      errors.add :password, 'Password cannot contain username'
    end
  end
end

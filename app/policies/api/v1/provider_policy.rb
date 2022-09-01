# frozen_string_literal: true

module Api
  module V1
    # pudit provider policy
    class ProviderPolicy < ApplicationPolicy
      def show?
        user.provider? || user.dbh_user?
      end

      def show_dbh?
        user.dbh_user?
      end

      def show_provider?
        user.provider?
      end
    end
  end
end

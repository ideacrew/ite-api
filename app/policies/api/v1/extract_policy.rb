# frozen_string_literal: true

module Api
  module V1
    # pudit extract policy
    class ExtractPolicy < ApplicationPolicy
      def ingest?
        user.provider?
      end

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

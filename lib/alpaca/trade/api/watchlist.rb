# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class Watchlist
        attr_reader :id, :account_id, :name, :created_at, :updated_at, :assets

        def initialize(json)
          @id = json['id']
          @account_id = json['account_id']
          @name = json['name']
          @created_at = json['created_at']
          @updated_at = json['updated_at']
          @assets = (json['assets'] || []).map { |item| Asset.new(item) }
        end
      end
    end
  end
end

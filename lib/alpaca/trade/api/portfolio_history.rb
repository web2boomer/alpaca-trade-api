# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class PortfolioHistory
        attr_reader :timestamp, :equity, :profit_loss, :profit_loss_pct, :base_value,
                    :base_value_asof, :timeframe, :cashflow

        def initialize(json)
          @timestamp = json['timestamp']
          @equity = json['equity']
          @profit_loss = json['profit_loss']
          @profit_loss_pct = json['profit_loss_pct']
          @base_value = json['base_value']
          @base_value_asof = json['base_value_asof']
          @timeframe = json['timeframe']
          @cashflow = json['cashflow']
        end
      end
    end
  end
end

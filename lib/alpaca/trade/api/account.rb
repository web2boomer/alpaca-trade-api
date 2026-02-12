# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class Account
        attr_reader :id, :status, :currency, :buying_power, :cash, :portfolio_value,
                    :pattern_day_trader, :trade_suspended_by_user, :trading_blocked,
                    :transfers_blocked, :account_blocked, :created_at, :shorting_enabled,
                    :multiplier, :long_market_value, :short_market_value, :equity,
                    :last_equity, :initial_margin, :maintenance_margin, :daytrade_count,
                    :sma, :regt_buying_power, :daytrading_buying_power,
                    :non_marginable_buying_power, :last_maintenance_margin

        def initialize(json)
          @id = json['id']
          @status = json['status']
          @currency = json['currency']
          @buying_power = to_decimal(json['buying_power'])
          @cash = to_decimal(json['cash'])
          @portfolio_value = to_decimal(json['portfolio_value'])
          @pattern_day_trader = json['pattern_day_trader']
          @trade_suspended_by_user = json['trade_suspended_by_user']
          @trading_blocked = json['trading_blocked']
          @transfers_blocked = json['transfers_blocked']
          @created_at = json['created_at']
          @shorting_enabled = json['shorting_enabled']
          @multiplier = json['multiplier']
          @long_market_value = to_decimal(json['long_market_value'])
          @short_market_value = to_decimal(json['short_market_value'])
          @equity = to_decimal(json['equity'])
          @last_equity = to_decimal(json['last_equity'])
          @initial_margin = to_decimal(json['initial_margin'])
          @maintenance_margin = to_decimal(json['maintenance_margin'])
          @daytrade_count = json['daytrade_count']
          @sma = json['sma']
          @regt_buying_power = to_decimal(json['regt_buying_power'])
          @daytrading_buying_power = to_decimal(json['daytrading_buying_power'])
          @non_marginable_buying_power = to_decimal(json['non_marginable_buying_power'])
          @last_maintenance_margin = to_decimal(json['last_maintenance_margin'])
        end

        private

        def to_decimal(value)
          value.nil? ? nil : BigDecimal(value)
        end
      end
    end
  end
end

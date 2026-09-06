# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class AccountConfiguration
        attr_reader :dtbp_check, :fractional_trading, :max_margin_multiplier, :no_shorting,
                    :pdt_check, :suspend_trade, :trade_confirm_email, :ptp_no_exception_entry,
                    :max_options_trading_level, :disable_overnight_trading

        def initialize(json)
          @dtbp_check = json['dtbp_check']
          @fractional_trading = json['fractional_trading']
          @max_margin_multiplier = json['max_margin_multiplier']
          @no_shorting = json['no_shorting']
          @pdt_check = json['pdt_check']
          @suspend_trade = json['suspend_trade']
          @trade_confirm_email = json['trade_confirm_email']
          @ptp_no_exception_entry = json['ptp_no_exception_entry']
          @max_options_trading_level = json['max_options_trading_level']
          @disable_overnight_trading = json['disable_overnight_trading']
        end
      end
    end
  end
end

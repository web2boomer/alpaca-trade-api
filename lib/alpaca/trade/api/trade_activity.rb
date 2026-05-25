# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class TradeActivity
        ATTRIBUTES = %w(id activity_type transaction_time type price qty side
                        symbol leaves_qty order_id cum_qty)

        attr_reader :id, :activity_type, :transaction_time, :type, :price, :qty,
                    :side, :symbol, :leaves_qty, :order_id, :cum_qty,
                    :commission, :fee, :fees, :regulatory_fees, :sec_fee,
                    :taf_fee, :clearing_fee, :currency, :raw_activity

        def initialize(json)
          @raw_activity = json
          @id = json['id']
          @activity_type = json['activity_type']
          @transaction_time = json['transaction_time']
          @type = json['type']
          @price = json['price']
          @qty = json['qty']
          @side = json['side']
          @symbol = json['symbol']
          @leaves_qty = json['leaves_qty']
          @order_id = json['order_id']
          @cum_qty = json['cum_qty']
          @commission = json['commission']
          @fee = json['fee']
          @fees = json['fees']
          @regulatory_fees = json['regulatory_fees']
          @sec_fee = json['sec_fee']
          @taf_fee = json['taf_fee']
          @clearing_fee = json['clearing_fee']
          @currency = json['currency']
        end
      end
    end
  end
end

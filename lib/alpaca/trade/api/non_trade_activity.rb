# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class NonTradeActivity
        attr_reader :id, :activity_type, :date, :net_ammount, :net_amount,
                    :symbol, :qty, :per_share_amount, :status,
                    :transaction_time, :executed_at, :settle_date,
                    :activity_created_at, :raw_activity

        def initialize(json)
          @raw_activity = json
          @id = json['id']
          @activity_type = json['activity_type']
          @date = json['date']
          @net_amount = json['net_amount'] || json['net_ammount']
          @net_ammount = @net_amount
          @symbol = json['symbol']
          @qty = json['qty']
          @per_share_amount = json['per_share_amount']
          @status = json['status']
          @transaction_time = json['transaction_time']
          @executed_at = json['executed_at']
          @settle_date = json['settle_date']
          @activity_created_at = json['created_at']
        end
      end
    end
  end
end

# frozen_string_literal: true

# object
# The best bid and ask information for a given security.

# t   date-time required          Timestamp in RFC-3339 format with nanosecond precision
# bx  string required             Bid exchange. See v2/stocks/meta/exchanges for more details.
# bp  double required             Bid price. 0 means the security has no active bid.
# bs  uint32 required             Bid size
# ax  string required             Ask exchange. See v2/stocks/meta/exchanges for more details.
# ap  double required             Ask price. 0 means the security has no active ask.
# as  uint32 required             Ask size
# c   array of strings required   Condition flags. See v2/stocks/meta/conditions/quote for more details. If the array contains one flag, it applies to both the bid and ask. If the array contains two flags, the first one applies to the bid and the second one to the ask.
# z   string required             Tape A is the New York Stock Exchange, Tape B is NYSE Arca, Bats, IEX and other regional exchanges, Tape C is NASDAQ, Tape O is OTC.
module Alpaca
  module Trade
    module Api
      class Quote
        attr_reader :time, :bid_exchange, :bid_price, :bid_size, :ask_exchange, :ask_price, :ask_size, :conditions, :tape

        def initialize(json)
          @time = Time.parse(json['t'])
          @bid_exchange = json['bx']
          @bid_price = BigDecimal(json['bp'].to_s)
          @bid_size = Integer(json['bs'].to_s)
          @ask_exchange = json['ax']
          @ask_price = BigDecimal(json['ap'].to_s)
          @ask_size = Integer(json['as'].to_s)
          @conditions = json['c']
          @tape = json['z']
        end
      end
    end
  end
end

# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class Trade
        attr_reader :time, :exchange, :price, :size, :conditions, :id, :tape

        def initialize(json)
          @time = Time.parse(json['t'])
          @exchange = json['x']
          @price = BigDecimal(json['p'].to_s)
          @size = json['s']
          @conditions = json['c']
          @id = json['i']
          @tape = json['z']
        end
      end
    end
  end
end

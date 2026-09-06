# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class Asset
        attr_reader :id, :asset_class, :exchange, :symbol, :name, :status, :tradable, :marginable,
                    :shortable, :easy_to_borrow, :fractionable, :maintenance_margin_requirement,
                    :margin_requirement_long, :margin_requirement_short, :attributes,
                    :borrow_status, :cusip, :min_order_size, :min_trade_increment, :price_increment

        def initialize(json)
          @id = json['id']
          @asset_class = json['class']
          @exchange = json['exchange']
          @symbol = json['symbol']
          @name = json['name']
          @status = json['status']
          @tradable = json['tradable']
          @marginable = json['marginable']
          @shortable = json['shortable']
          @easy_to_borrow = json['easy_to_borrow']
          @fractionable = json['fractionable']
          @maintenance_margin_requirement = json['maintenance_margin_requirement']
          @margin_requirement_long = json['margin_requirement_long']
          @margin_requirement_short = json['margin_requirement_short']
          @attributes = json['attributes']
          @borrow_status = json['borrow_status']
          @cusip = json['cusip']
          @min_order_size = json['min_order_size']
          @min_trade_increment = json['min_trade_increment']
          @price_increment = json['price_increment']
        end
      end
    end
  end
end

# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class OptionContract
        attr_reader :id, :symbol, :name, :status, :tradable, :expiration_date,
                    :underlying_symbol, :underlying_asset_id, :type, :style, :strike_price,
                    :multiplier, :size, :open_interest, :open_interest_date, :close_price,
                    :close_price_date, :root_symbol, :deliverables

        def initialize(json)
          @id = json['id']
          @symbol = json['symbol']
          @name = json['name']
          @status = json['status']
          @tradable = json['tradable']
          @expiration_date = json['expiration_date']
          @underlying_symbol = json['underlying_symbol']
          @underlying_asset_id = json['underlying_asset_id']
          @type = json['type']
          @style = json['style']
          @strike_price = json['strike_price']
          @multiplier = json['multiplier']
          @size = json['size']
          @open_interest = json['open_interest']
          @open_interest_date = json['open_interest_date']
          @close_price = json['close_price']
          @close_price_date = json['close_price_date']
          @root_symbol = json['root_symbol']
          @deliverables = json['deliverables']
        end
      end
    end
  end
end

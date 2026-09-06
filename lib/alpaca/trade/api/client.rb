# frozen_string_literal: true

require 'date'
require 'faraday'

module Alpaca
  module Trade
    module Api
      class Client
        attr_reader :data_endpoint, :endpoint, :key_id, :key_secret

        def initialize(endpoint: Alpaca::Trade::Api.configuration.endpoint,
                       key_id: Alpaca::Trade::Api.configuration.key_id,
                       key_secret: Alpaca::Trade::Api.configuration.key_secret)
          @data_endpoint = Alpaca::Trade::Api.configuration.data_endpoint
          @endpoint = endpoint
          @key_id = key_id
          @key_secret = key_secret
        end

        def account
          response = get_request(endpoint, 'v2/account')
          Account.new(JSON.parse(response.body))
        end

        def account_activities(activity_type: nil, date:nil, after:nil, until_time:nil, direction:nil, page_size:nil, page_token:nil)
          if !date.nil? && (!until_time.nil? || !after.nil?)
            raise InvalidParameters, 'date cannot be used with either until_time or after'
          end
          params = { date:date, until_time:until_time, after:after, direction:direction, page_size:page_size, page_token:page_token }.compact
          path = activity_type ? "/v2/account/activities/#{activity_type}" : '/v2/account/activities'
          response = get_request(endpoint, path, params)
          raise InvalidActivityType, JSON.parse(response.body)['message'] if response.status == 422
          json = JSON.parse(response.body)
          return [] if json.nil? || json.empty?

          json.map do |item|
            activity_class = (TradeActivity::ATTRIBUTES - item.to_h.keys).none? ? TradeActivity : NonTradeActivity
            activity_class.new(item)
          end
        end

        def account_configurations
          response = get_request(endpoint, 'v2/account/configurations')
          AccountConfiguration.new(JSON.parse(response.body))
        end

        def update_account_configurations(**attrs)
          response = patch_request(endpoint, 'v2/account/configurations', attrs.compact)
          AccountConfiguration.new(JSON.parse(response.body))
        end

        def announcements(ca_types:, since:, until_date:, symbol: nil, cusip: nil, date_type: nil)
          params = {
            ca_types: Array(ca_types).join(','),
            since: since,
            until: until_date,
            symbol: symbol,
            cusip: cusip,
            date_type: date_type
          }.compact
          response = get_request(endpoint, 'v2/corporate_actions/announcements', params)
          json = JSON.parse(response.body)
          json.map { |item| Announcement.new(item) }
        end

        def announcement(id:)
          response = get_request(endpoint, "v2/corporate_actions/announcements/#{id}")
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          Announcement.new(JSON.parse(response.body))
        end

        def portfolio_history(period: nil, timeframe: nil, start_time: nil, end_time: nil,
                              date_end: nil, extended_hours: nil, force_endcap: nil,
                              intraday_reporting: nil, pnl_reset: nil, cashflow_types: nil)
          params = {
            period: period,
            timeframe: timeframe,
            start: start_time,
            end: end_time,
            date_end: date_end,
            extended_hours: extended_hours,
            force_endcap: force_endcap,
            intraday_reporting: intraday_reporting,
            pnl_reset: pnl_reset,
            cashflow_types: cashflow_types
          }.compact
          response = get_request(endpoint, 'v2/account/portfolio/history', params)
          raise InvalidParameters, JSON.parse(response.body)['message'] if response.status == 400

          PortfolioHistory.new(JSON.parse(response.body))
        end

        def asset(symbol:)
          response = get_request(endpoint, "v2/assets/#{symbol}")
          Asset.new(JSON.parse(response.body))
        end

        def assets(status: nil, asset_class: nil, exchange: nil, attributes: nil)
          params = {
            status: status,
            asset_class: asset_class,
            exchange: exchange,
            attributes: attributes
          }.compact
          response = get_request(endpoint, "v2/assets", params)
          json = JSON.parse(response.body)
          json.map { |item| Asset.new(item) }
        end

        # {
        #   "quotes": {
        #     "NET": {
        #       "ap": 81.86,
        #       "as": 4,
        #       "ax": "P",
        #       "bp": 81.48,
        #       "bs": 4,
        #       "bx": "P",
        #       "c": [
        #         "R"
        #       ],
        #       "t": "2024-01-25T22:20:56.83785216Z",
        #       "z": "A"
        #     }
        #   }
        # }
        def latest_quote(symbols:)
          validate_symbols(symbols)
          response = get_request(data_endpoint, "v2/stocks/quotes/latest", { symbols: prepare_symbols(symbols) })
          json = JSON.parse(response.body)

          hash = { "next_page_token" => json["next_page_token"], "quotes" => {} }
          if json["quotes"].count > 0
            ensure_symbols_are_array(symbols).each do |symbol|
              hash["quotes"][symbol] = Quote.new(json["quotes"][symbol]) 
            end   
          end
          hash       
        end

        def latest_trade(symbols:, feed: nil)
          validate_symbols(symbols)
          params = { symbols: prepare_symbols(symbols) }
          params[:feed] = feed if feed
          response = get_request(data_endpoint, "v2/stocks/trades/latest", params)
          json = JSON.parse(response.body)

          hash = { "next_page_token" => json["next_page_token"], "trades" => {} }
          trades = json["trades"] || {}
          ensure_symbols_are_array(symbols).each do |symbol|
            hash["trades"][symbol] = Trade.new(trades[symbol]) if trades[symbol]
          end
          hash
        end          

        # {
        #   "bars": {
        #     "AAPL": [
        #       {
        #         "t": "2022-01-03T09:00:00Z",
        #         "o": 178.26,
        #         "h": 178.26,
        #         "l": 178.21,
        #         "c": 178.21,git 
        #         "v": 1118,
        #         "n": 65,
        #         "vw": 178.235733
        #       }
        #     ]
        #   },
        #   "next_page_token": "QUFQTHxNfDIwMjItMDEtMDNUMDk6MDA6MDAuMDAwMDAwMDAwWg=="
        # }
        VALID_TIMEFRAMES = %w[1Min 5Min 15Min 30Min 1Hour 1Day 1D 1Week 1Month].freeze

        # `adjustment` — one of "raw" (default; matches Alpaca API default),
        # "split", "dividend", or "all". Pass "all" for any multi-day analysis
        # so corporate actions don't show up as fake price moves.
        def bars(timeframe: '1D', symbols:, limit: 100, start_date: nil, end_date: nil, feed: 'sip', asof: nil, adjustment: nil)
          validate_symbols(symbols)
          validate_timeframe(timeframe)

          params = {
            symbols: prepare_symbols(symbols),
            limit: limit,
            timeframe: timeframe,
            feed: feed
          }
          params[:start] = start_date.rfc3339 if start_date
          params[:end]  = end_date.rfc3339 if end_date

          params[:asof] = asof.strftime("%Y-%m-%d") if asof.is_a?(Date) || asof.is_a?(Time)
          params[:asof] ||= asof if asof.is_a?(String)

          params[:adjustment] = adjustment if adjustment

          response = get_request(data_endpoint, "v2/stocks/bars", params)
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404
          raise InvalidParameters, JSON.parse(response.body)['message'] if response.status == 400

          json = JSON.parse(response.body)
          hash = { "next_page_token" => json["next_page_token"], "bars" => {} }
          ensure_symbols_are_array(symbols).each do |symbol|
            hash["bars"][symbol] = json["bars"][symbol]&.map { |bar| Bar.new(bar) } || []
          end
          hash
        end

        def calendar(start_date: Date.today, end_date: (Date.today + 30))
          # FIX, use start_date.strftime('%F')
          params = { "start" => start_date.iso8601, "end" => end_date.iso8601 }
          response = get_request(endpoint, "v2/calendar", params)
          json = JSON.parse(response.body)
          json.map { |item| Calendar.new(item) }
        end

        def cancel_order(id:)
          response = delete_request(endpoint, "v2/orders/#{id}")
          raise InvalidOrderId, JSON.parse(response.body)['message'] if response.status == 404
          raise OrderNotCancelable if response.status == 422
        end

        def cancel_orders
          response = delete_request(endpoint, 'v2/orders')

          json = JSON.parse(response.body)
          json.map do |item|
            {
              'id' => item['id'],
              'status' => item['status'],
              'body' => Order.new(item['body']),
            }
          end
        end

        def clock
          response = get_request(endpoint, 'v2/clock')
          Clock.new(JSON.parse(response.body))
        end

        def close_position(symbol:, qty: nil, percentage: nil)
          params = { qty: qty, percentage: percentage }.compact
          response = delete_request(endpoint, "v2/positions/#{symbol}", params)
          raise NoPositionForSymbol, JSON.parse(response.body)['message'] if response.status == 404
          # e.g. 403 "insufficient qty available" when open orders hold shares
          raise PositionNotClosable, JSON.parse(response.body)['message'] unless (200..299).cover?(response.status)

          # DELETE /v2/positions/{symbol} returns the liquidating Order, not a Position.
          Order.new(JSON.parse(response.body))
        end

        def close_positions
          response = delete_request(endpoint, 'v2/positions')

          json = JSON.parse(response.body)
          json.map do |item|
            {
              'symbol' => item['symbol'],
              'status' => item['status'],
              # Each item body is the liquidating Order for that symbol.
              'body' => Order.new(item['body']),
            }
          end
        end

        def last_trade(symbol:)
          response = get_request(data_endpoint, "v1/last/stocks/#{symbol}")
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          LastTrade.new(JSON.parse(response.body))
        end

        def new_order(symbol:, side:, type:, time_in_force:, qty: nil, notional: nil,
          limit_price: nil, stop_price: nil, extended_hours: false, client_order_id: nil,
          order_class: nil, take_profit: nil, stop_loss: nil,
          trail_price: nil, trail_percent: nil, position_intent: nil)

          params = {
            symbol: symbol,
            side: side,
            type: type,
            time_in_force: time_in_force,
            qty: qty,
            notional: notional,
            limit_price: limit_price,
            order_class: order_class,
            stop_price: stop_price,
            take_profit: take_profit,
            stop_loss: stop_loss,
            extended_hours: extended_hours,
            client_order_id: client_order_id,
            trail_price: trail_price,
            trail_percent: trail_percent,
            position_intent: position_intent
          }
          response = post_request(endpoint, 'v2/orders', params.compact)
          raise InsufficientFunds, JSON.parse(response.body)['message'] if response.status == 403
          raise MissingParameters, JSON.parse(response.body)['message'] if response.status == 422

          Order.new(JSON.parse(response.body))
        end

        # Multi-leg options order (order_class "mleg"). `legs` is an array of
        # { symbol:, ratio_qty:, side:, position_intent: } hashes. `limit_price`
        # is the net price for the whole structure — negative for a net credit.
        def new_mleg_order(legs:, qty:, type: 'limit', time_in_force: 'day',
          limit_price: nil, client_order_id: nil)

          params = {
            order_class: 'mleg',
            qty: qty.to_s,
            type: type,
            time_in_force: time_in_force,
            limit_price: limit_price&.to_s,
            client_order_id: client_order_id,
            legs: legs
          }
          response = post_request(endpoint, 'v2/orders', params.compact)
          raise InsufficientFunds, JSON.parse(response.body)['message'] if response.status == 403
          raise MissingParameters, JSON.parse(response.body)['message'] if response.status == 422

          Order.new(JSON.parse(response.body))
        end

        def order(id: nil, client_order_id: nil)
          if id.nil? && client_order_id.nil?
            raise InvalidParameters, 'id or client_order_id is required'
          end

          response = if client_order_id
            get_request(endpoint, 'v2/orders:by_client_order_id', { client_order_id: client_order_id })
          else
            get_request(endpoint, "v2/orders/#{id}")
          end
          raise InvalidOrderId, JSON.parse(response.body)['message'] if response.status == 404

          Order.new(JSON.parse(response.body))
        end

        def orders(status: nil, symbols: nil, after: nil, until_time: nil, direction: nil, limit: 50,
                   nested: nil, side: nil)
          params = {
            status: status,
            symbols: symbols,
            after: after,
            until: until_time,
            direction: direction,
            limit: limit,
            nested: nested,
            side: side
          }
          response = get_request(endpoint, "v2/orders", params.compact)
          json = JSON.parse(response.body)
          json.map { |item| Order.new(item) }
        end

        def position(symbol: nil)
          response = get_request(endpoint, ["v2/positions", symbol].compact.join('/'))
          raise NoPositionForSymbol, JSON.parse(response.body)['message'] if response.status == 404

          Position.new(JSON.parse(response.body))
        end

        def positions(symbol: nil)
          response = get_request(endpoint, ["v2/positions", symbol].compact.join('/'))
          json = JSON.parse(response.body)
          json.map { |item| Position.new(item) }
        end

        def option_contract(symbol_or_id:)
          response = get_request(endpoint, "v2/options/contracts/#{symbol_or_id}")
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          OptionContract.new(JSON.parse(response.body))
        end

        def exercise_option(symbol_or_contract_id:, qty: nil)
          params = { qty: qty }.compact
          response = post_request(endpoint, "v2/positions/#{symbol_or_contract_id}/exercise", params)
          raise NoPositionForSymbol, JSON.parse(response.body)['message'] if response.status == 404
          raise InvalidRequest, JSON.parse(response.body)['message'] unless (200..299).cover?(response.status)

          body = response.body.to_s.strip
          return nil if body.empty?

          JSON.parse(body)
        end

        def option_contracts(underlying_symbols:, expiration_date_gte: nil, expiration_date_lte: nil, status: 'active', limit: 500)
          params = {
            underlying_symbols: underlying_symbols,
            expiration_date_gte: expiration_date_gte,
            expiration_date_lte: expiration_date_lte,
            status: status,
            limit: limit,
          }.compact
          response = get_request(endpoint, 'v2/options/contracts', params)
          JSON.parse(response.body)
        end

        def option_snapshots(symbols:, feed: 'indicative')
          params = {
            symbols: prepare_symbols(symbols),
            feed: feed,
          }
          response = get_request(data_endpoint, 'v1beta1/options/snapshots', params)
          JSON.parse(response.body)
        end

        def watchlists
          response = get_request(endpoint, 'v2/watchlists')
          json = JSON.parse(response.body)
          json.map { |item| Watchlist.new(item) }
        end

        def watchlist(id: nil, name: nil)
          if id.nil? && name.nil?
            raise InvalidParameters, 'id or name is required'
          end

          response = if name
            get_request(endpoint, 'v2/watchlists:by_name', { name: name })
          else
            get_request(endpoint, "v2/watchlists/#{id}")
          end
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          Watchlist.new(JSON.parse(response.body))
        end

        def create_watchlist(name:, symbols: [])
          response = post_request(endpoint, 'v2/watchlists', { name: name, symbols: symbols })
          Watchlist.new(JSON.parse(response.body))
        end

        def update_watchlist(id:, name: nil, symbols: nil)
          params = { name: name, symbols: symbols }.compact
          response = put_request(endpoint, "v2/watchlists/#{id}", params)
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          Watchlist.new(JSON.parse(response.body))
        end

        def delete_watchlist(id:)
          response = delete_request(endpoint, "v2/watchlists/#{id}")
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404
        end

        def add_to_watchlist(id:, symbol:)
          response = post_request(endpoint, "v2/watchlists/#{id}", { symbol: symbol })
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          Watchlist.new(JSON.parse(response.body))
        end

        def remove_from_watchlist(id:, symbol:)
          response = delete_request(endpoint, "v2/watchlists/#{id}/#{symbol}")
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 404

          Watchlist.new(JSON.parse(response.body))
        end

        def replace_order(id:, qty: nil, time_in_force: nil, limit_price: nil,
                          stop_price: nil, client_order_id: nil)

          params = {
            qty: qty,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: stop_price,
            client_order_id: client_order_id
          }
          response = patch_request(endpoint, "v2/orders/#{id}", params.compact)
          raise InsufficientFunds, JSON.parse(response.body)['message'] if response.status == 403
          raise InvalidOrderId, JSON.parse(response.body)['message'] if response.status == 404
          raise InvalidRequest, JSON.parse(response.body)['message'] if response.status == 422

          Order.new(JSON.parse(response.body))
        end

        private

        def delete_request(endpoint, uri, params = {})
          conn = Faraday.new(url: endpoint)
          response = conn.delete(uri) do |req|
            params.each { |k, v| req.params[k.to_s] = v }
            req.headers['APCA-API-KEY-ID'] = key_id
            req.headers['APCA-API-SECRET-KEY'] = key_secret
          end

          possibly_raise_exception(response)
          response
        end

        def get_request(endpoint, uri, params = {})
          conn = Faraday.new(url: endpoint) do |f|
            f.options.open_timeout = 5
            f.options.timeout = 15
          end
          response = conn.get(uri) do |req|
            params.each { |k, v| req.params[k.to_s] = v }
            req.headers['APCA-API-KEY-ID'] = key_id
            req.headers['APCA-API-SECRET-KEY'] = key_secret
          end

          possibly_raise_exception(response)
          response
        end

        def put_request(endpoint, uri, params = {})
          conn = Faraday.new(url: endpoint)
          response = conn.put(uri) do |req|
            req.body = params.to_json
            req.headers['APCA-API-KEY-ID'] = key_id
            req.headers['APCA-API-SECRET-KEY'] = key_secret
          end

          possibly_raise_exception(response)
          response
        end

        def patch_request(endpoint, uri, params = {})
          conn = Faraday.new(url: endpoint)
          response = conn.patch(uri) do |req|
            req.body = params.to_json
            req.headers['APCA-API-KEY-ID'] = key_id
            req.headers['APCA-API-SECRET-KEY'] = key_secret
          end

          possibly_raise_exception(response)
          response
        end

        def post_request(endpoint, uri, params = {})
          conn = Faraday.new(url: endpoint)
          response = conn.post(uri) do |req|
            req.body = params.to_json
            req.headers['APCA-API-KEY-ID'] = key_id
            req.headers['APCA-API-SECRET-KEY'] = key_secret
          end

          possibly_raise_exception(response)
          response
        end

        def ensure_symbols_are_array(symbols)
          symbols = [symbols] if symbols.is_a?(String)
          symbols
        end

        def prepare_symbols(symbols)
          symbols = ensure_symbols_are_array(symbols)
          symbols.join(',')
        end


        def possibly_raise_exception(response)
          if response.status == 401
            raise UnauthorizedError, response.body
          end
          if response.status == 429
            raise RateLimitedError,  response.body
          end
          if response.status == 500
            raise InternalServerError, response.body
          end
          if response.status == 502
            raise BadGatewayError, response.body
          end
        end

        def validate_symbols(symbols)
          return if symbols.is_a?(String)
          return if symbols.is_a?(Array) && symbols.all?{ |symbol| symbol.is_a?(String) }
          raise ArgumentError, "Invalid symbols: #{symbols.inspect}. Symbols must be a String or an array of strings."
        end

        def validate_timeframe(timeframe)
          return if VALID_TIMEFRAMES.include?(timeframe)
          raise ArgumentError, "Invalid timeframe: #{timeframe.inspect}. Valid timeframes are: #{VALID_TIMEFRAMES.join(', ')}."
        end
      end
    end
  end
end

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.11.0] - 2026-09-06
### Added
- Asset fields: `name`, `attributes`, `borrow_status`, `cusip`, `margin_requirement_long`, `margin_requirement_short`, crypto increments, plus `Client#assets` `exchange`/`attributes` filters.
- Account fields: `account_number`, `account_blocked`, options buying power/levels, fees, transfers, `balance_asof`, `crypto_status`, and related money fields.
- Position fields: `qty_available`, `swap_rate`, `avg_entry_swap_rate`, `usd`.
- Order fields: `notional`, `expires_at`, `hwm`, `position_intent`, `ratio_qty`, `order_type`.
- `Client#new_order` now accepts `trail_price`, `trail_percent`, and `position_intent`.
- `Client#order` can look up by `client_order_id`. `Client#orders` accepts `nested` and `side`.
- `Client#close_position` accepts `qty` and `percentage`.
- `Client#account_activities` can omit `activity_type` to list all activities.
- Trading API coverage: account configurations, watchlists, portfolio history, corporate-action announcements, option contract by id, option exercise.
- `Client#latest_trade` uses the current Market Data v2 latest-trades endpoint.

### Fixed
- `Account#account_blocked` is now assigned from the API payload.

## [0.10.1] - 2026-08-06
### Fixed
- `Client#close_position` and `Client#close_positions` now return `Order` objects, matching Alpaca's `DELETE /v2/positions` response (was incorrectly wrapped as `Position`).

## [0.9.0] - 2022-04-10
### Added
- Added trail_percent and trail_price to orders

## [0.8.0] - 2021-04-20
### Added
- Added fractionable and notional orders

## [0.7.0] - 2021-02-27
### Added
- Support for `faraday` 1.x.

## [0.6.0] - 2020-05-26
### Added
- Implemented Client#account_activities. Thanks @travishooper.

## [0.5.0] - 2020-05-25
### Added
- Implemented Client#last_trade. Thanks @nathanworden.

## [0.4.1] - 2020-04-25
### Fixed
- Added explicit `BigDecimal` require.

## [0.4.0] - 2020-02-16
### Added
- Supporting [Bracket Orders](https://docs.alpaca.markets/trading-on-alpaca/orders/#bracket-orders)
- Validating time frame in Client#bars

## [0.3.0] - 2019-09-19
### Added
- Implemented new endpoints:
  * Client#cancel_orders
  * Client#close_position
  * Client#close_positions
  * Client#replace_order
- Added limit as a parameter to Client#bars
- Renamed Clock#open to Clock#is_open and fixed assignment.

## [0.2.0] - 2019-07-10
### Added
- Implemented Client#calendar.
- Implemented Client#clock.
- Added Client#assets.
- Implemented new methods in Client: new_order, order, orders, position, positions.
- Implemented Client#cancel_order.

## [0.1.0] - 2019-07-04
### Added
- First version of gem.
- Includes support for account, asset, and data endpoints.

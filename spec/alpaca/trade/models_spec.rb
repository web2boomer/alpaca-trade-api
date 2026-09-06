# frozen_string_literal: true

RSpec.describe 'API models' do
  describe Alpaca::Trade::Api::Asset do
    it 'parses current and deprecated margin fields' do
      asset = described_class.new(
        'id' => 'asset-1',
        'class' => 'us_equity',
        'exchange' => 'NASDAQ',
        'symbol' => 'AAPL',
        'name' => 'Apple Inc. Common Stock',
        'status' => 'active',
        'tradable' => true,
        'marginable' => true,
        'shortable' => true,
        'easy_to_borrow' => true,
        'fractionable' => true,
        'maintenance_margin_requirement' => 0.30,
        'margin_requirement_long' => '100',
        'margin_requirement_short' => '30',
        'attributes' => ['has_options'],
        'borrow_status' => 'easy_to_borrow',
        'cusip' => '037833100',
        'min_order_size' => '0.0001',
        'min_trade_increment' => '0.0001',
        'price_increment' => '0.01'
      )

      expect(asset.asset_class).to eq('us_equity')
      expect(asset.name).to eq('Apple Inc. Common Stock')
      expect(asset.maintenance_margin_requirement).to eq(0.30)
      expect(asset.margin_requirement_long).to eq('100')
      expect(asset.margin_requirement_short).to eq('30')
      expect(asset.attributes).to eq(['has_options'])
      expect(asset.borrow_status).to eq('easy_to_borrow')
      expect(asset.cusip).to eq('037833100')
      expect(asset.min_order_size).to eq('0.0001')
    end
  end

  describe Alpaca::Trade::Api::Account do
    it 'parses margin and options fields and leaves missing money fields as nil' do
      account = described_class.new(
        'id' => 'acct-1',
        'account_number' => 'PA123',
        'status' => 'ACTIVE',
        'crypto_status' => 'ACTIVE',
        'currency' => 'USD',
        'buying_power' => '100.00',
        'cash' => '50.00',
        'portfolio_value' => '150.00',
        'pattern_day_trader' => false,
        'account_blocked' => false,
        'trading_blocked' => false,
        'transfers_blocked' => false,
        'long_market_value' => '100.00',
        'short_market_value' => '0',
        'equity' => '150.00',
        'last_equity' => '140.00',
        'initial_margin' => '10.00',
        'maintenance_margin' => '5.00',
        'regt_buying_power' => '200.00',
        'daytrading_buying_power' => '400.00',
        'non_marginable_buying_power' => '50.00',
        'last_maintenance_margin' => '4.00',
        'options_buying_power' => '80.00',
        'options_approved_level' => 2,
        'options_trading_level' => 1,
        'accrued_fees' => '0',
        'pending_reg_taf_fees' => '0.04',
        'intraday_adjustments' => '0',
        'pending_transfer_in' => '1.00',
        'balance_asof' => '2026-09-01',
        'effective_buying_power' => '100.00',
        'position_market_value' => '100.00',
        'crypto_tier' => 1
      )

      expect(account.account_number).to eq('PA123')
      expect(account.account_blocked).to eq(false)
      expect(account.regt_buying_power).to eq(BigDecimal('200.00'))
      expect(account.options_buying_power).to eq(BigDecimal('80.00'))
      expect(account.options_approved_level).to eq(2)
      expect(account.pending_transfer_out).to be_nil
      expect(account.balance_asof).to eq('2026-09-01')
    end
  end

  describe Alpaca::Trade::Api::Position do
    it 'parses qty_available and asset_marginable' do
      position = described_class.new(
        'asset_id' => 'a',
        'symbol' => 'AAPL',
        'qty' => '5',
        'qty_available' => '4',
        'asset_marginable' => true,
        'swap_rate' => '1.0',
        'usd' => { 'market_value' => '600' }
      )

      expect(position.qty_available).to eq('4')
      expect(position.asset_marginable).to eq(true)
      expect(position.usd).to eq('market_value' => '600')
    end
  end

  describe Alpaca::Trade::Api::Order do
    it 'parses notional, expires_at, and options fields' do
      order = described_class.new(
        'id' => 'o1',
        'notional' => '500',
        'expires_at' => '2026-09-07T20:00:00Z',
        'hwm' => '12.5',
        'position_intent' => 'buy_to_open',
        'ratio_qty' => '1',
        'order_type' => 'limit',
        'legs' => [{ 'id' => 'leg-1', 'symbol' => 'AAPL' }]
      )

      expect(order.notional).to eq('500')
      expect(order.expires_at).to eq('2026-09-07T20:00:00Z')
      expect(order.position_intent).to eq('buy_to_open')
      expect(order.legs.first).to be_an(described_class)
    end
  end

  describe Alpaca::Trade::Api::AccountConfiguration do
    it 'parses configuration flags' do
      config = described_class.new(
        'fractional_trading' => true,
        'max_margin_multiplier' => '4',
        'no_shorting' => false,
        'disable_overnight_trading' => false,
        'max_options_trading_level' => 3
      )

      expect(config.fractional_trading).to eq(true)
      expect(config.max_margin_multiplier).to eq('4')
      expect(config.max_options_trading_level).to eq(3)
    end
  end

  describe Alpaca::Trade::Api::Watchlist do
    it 'maps nested assets and defaults to an empty list' do
      with_assets = described_class.new(
        'id' => 'w1',
        'name' => 'Primary',
        'assets' => [{ 'id' => 'a1', 'class' => 'us_equity', 'symbol' => 'AAPL' }]
      )
      without_assets = described_class.new('id' => 'w2', 'name' => 'Empty')

      expect(with_assets.assets.first).to be_an(Alpaca::Trade::Api::Asset)
      expect(with_assets.assets.first.symbol).to eq('AAPL')
      expect(without_assets.assets).to eq([])
    end
  end

  describe Alpaca::Trade::Api::PortfolioHistory do
    it 'parses timeseries fields' do
      history = described_class.new(
        'timestamp' => [1, 2],
        'equity' => [100, 110],
        'profit_loss' => [0, 10],
        'profit_loss_pct' => [0, 0.1],
        'base_value' => 100,
        'timeframe' => '1D'
      )

      expect(history.equity).to eq([100, 110])
      expect(history.timeframe).to eq('1D')
    end
  end

  describe Alpaca::Trade::Api::Announcement do
    it 'parses corporate action fields' do
      announcement = described_class.new(
        'id' => 'ann-1',
        'corporate_action_id' => 'BAC_AD21',
        'ca_type' => 'Dividend',
        'ca_sub_type' => 'cash',
        'initiating_symbol' => 'BAC',
        'cash' => '0.21'
      )

      expect(announcement.ca_type).to eq('Dividend')
      expect(announcement.initiating_symbol).to eq('BAC')
    end
  end

  describe Alpaca::Trade::Api::OptionContract do
    it 'parses contract fields' do
      contract = described_class.new(
        'id' => 'c1',
        'symbol' => 'AAPL250620C00100000',
        'type' => 'call',
        'style' => 'american',
        'strike_price' => '100',
        'underlying_symbol' => 'AAPL'
      )

      expect(contract.type).to eq('call')
      expect(contract.strike_price).to eq('100')
    end
  end

  describe Alpaca::Trade::Api::Trade do
    it 'parses a latest stock trade' do
      trade = described_class.new(
        't' => '2022-01-03T09:00:00.086175744Z',
        'x' => 'P',
        'p' => 178.26,
        's' => 246,
        'c' => ['@', 'T'],
        'i' => 1,
        'z' => 'C'
      )

      expect(trade.price).to eq(BigDecimal('178.26'))
      expect(trade.exchange).to eq('P')
      expect(trade.size).to eq(246)
    end
  end
end

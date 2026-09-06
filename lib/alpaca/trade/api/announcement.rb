# frozen_string_literal: true

module Alpaca
  module Trade
    module Api
      class Announcement
        attr_reader :id, :corporate_action_id, :ca_type, :ca_sub_type, :initiating_symbol,
                    :initiating_original_cusip, :target_symbol, :target_original_cusip,
                    :declaration_date, :effective_date, :ex_date, :record_date, :payable_date,
                    :cash, :old_rate, :new_rate

        def initialize(json)
          @id = json['id']
          @corporate_action_id = json['corporate_action_id']
          @ca_type = json['ca_type']
          @ca_sub_type = json['ca_sub_type']
          @initiating_symbol = json['initiating_symbol']
          @initiating_original_cusip = json['initiating_original_cusip']
          @target_symbol = json['target_symbol']
          @target_original_cusip = json['target_original_cusip']
          @declaration_date = json['declaration_date']
          @effective_date = json['effective_date']
          @ex_date = json['ex_date']
          @record_date = json['record_date']
          @payable_date = json['payable_date']
          @cash = json['cash']
          @old_rate = json['old_rate']
          @new_rate = json['new_rate']
        end
      end
    end
  end
end

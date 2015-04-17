module Spree
  module Admin
    GeneralSettingsController.class_eval do
      before_action :update_currency_settings, only: :update

      def render(*args)
        @preferences_currency |= [:allow_currency_change, :show_currency_selector, :supported_currencies]
        super
      end

      def calculate_prices
        main_currency = Spree::Config.currency
        supported_currencies = Spree::Config.supported_currencies.split(',').map(&:strip)
        supported_currencies.delete(main_currency)

        rates = get_rates(main_currency, supported_currencies)

        supported_currencies.each do |currency|
          # we need to change to all the currencies, because price_in(currency).amount= does not work
          Spree::Config.currency = currency
          Spree::Product.transaction do
            Spree::Product.find_each(batch_size: 300) do |product|
              main_price = product.price_in(main_currency).amount
              product.price = round_price(rates[currency] * main_price)
              product.variants.each do |variant|
                variant_main_price = variant.price_in(main_currency).amount
                variant.price = round_price(rates[currency] * variant_main_price)
                variant.save
              end
              product.save
            end
          end
        end
        Spree::Config.currency = main_currency
        head :no_content
      end

      private

      def get_rates(in_currency, currencies)
        rates = {}
        currencies.each do |to_currency|
          doc = Net::HTTP.get('www.google.com', "/finance/converter?a=1&from=#{in_currency}&to=#{to_currency}")
          regexp = Regexp.new("(\\d+\\.{0,1}\\d*)\\s+#{to_currency}")
          regexp.match doc
          rates[to_currency] = $1.to_f
        end
        return rates
      end

      def round_price(price)
        if Spree::Config.round_calculated_prices
          decimal_places = price.to_i.to_s.length
          if decimal_places <= 1
            price.ceil
          elsif decimal_places == 2 or decimal_places == 3
            (price / 5).ceil * 5
          else
            price.ceil(2 - decimal_places)
          end
        else
          price
        end
      end

      def update_currency_settings
        params.each do |name, value|
          next unless Spree::Config.has_preference? name
          if name == 'supported_currencies'
            value = value.split(',').map { |curr| ::Money::Currency.find(curr.strip).try(:iso_code) }.concat([Spree::Config[:currency]]).uniq.compact.join(',')
          end
          Spree::Config[name] = value
        end
      end
    end
  end
end

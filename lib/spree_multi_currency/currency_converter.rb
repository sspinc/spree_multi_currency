module SpreeMultiCurrency
  class CurrencyConverter
    def self.calculate_price
      new.calculate_prices
    end

    def initialize (get_rates: SpreeMultiCurrency::GetRates, round_price: SpreeMultiCurrency::RoundPrice)
      @get_rates = get_rates.new
      @round_price = round_price.new
    end

    def calculate_prices
      main_currency = Spree::Config.currency
      supported_currencies = Spree::Config.supported_currencies.split(',').map(&:strip)
      supported_currencies.delete(main_currency)

      rates = @get_rates.call(main_currency, supported_currencies)

      supported_currencies.each do |currency|
        # we need to change to all the currencies, because price_in(currency).amount= does not work
        Spree::Config.currency = currency
        Spree::Product.transaction do
          Spree::Product.find_each(batch_size: 300) do |product|
            main_price = product.price_in(main_currency).amount
            product.price = @round_price.call(rates[currency] * main_price)
            product.variants.each do |variant|
              variant_main_price = variant.price_in(main_currency).amount
              variant.price = @round_price.call(rates[currency] * variant_main_price)
              variant.save
            end
            product.save
          end
        end
      end
      Spree::Config.currency = main_currency
    end
  end
end

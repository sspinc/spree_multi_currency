module Spree
  module Admin
    GeneralSettingsController.class_eval do
      before_action :update_currency_settings, only: :update

      def render(*args)
        @preferences_currency |= [:allow_currency_change, :show_currency_selector, :supported_currencies]
        super
      end

      def calculate_currencies
        puts "Calculatin currencies"

        # TODO: Hardcoding the exchange rates for now, should be fetched later
        rates = { USD: { EUR: 0.94, GBP: 0.68, MXN: 15.24, CAD: 1.27 } }.deep_stringify_keys

        main_currency = Spree::Config.currency
        supported_currencies = Spree::Config.supported_currencies.split(', ')
        supported_currencies.delete(main_currency)

        #Update master variant prices
        supported_currencies.each do |currency|
          # we need to change currencies, because price_in.amount= does not seem to work
          Spree::Config.currency = currency
          Spree::Product.all.each do |product|
            main_price = product.price_in(main_currency).amount
            product.price = rates[main_currency][currency] * main_price
            product.variants.each do |variant|
              variant_main_price = variant.price_in(main_currency).amount
              variant.price = rates[main_currency][currency] * variant_main_price
              variant.save
            end
            product.save
          end
        end
        Spree::Config.currency = main_currency
        head :no_content
#        render :status => 400
      end

      private

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

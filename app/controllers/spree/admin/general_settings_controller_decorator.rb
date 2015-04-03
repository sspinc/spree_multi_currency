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

        # Hardcoding the exchange rates for now
        usd_to_eur = 0.94
        usd_to_gbp = 0.68
        usd_to_mxn = 15.24
        usd_to_cad = 1.27


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

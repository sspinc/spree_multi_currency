module SpreeMultiCurrency
  class RoundPrice
    def self.call(price)
      new.call(price)
    end

    def call(price)
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
  end
end

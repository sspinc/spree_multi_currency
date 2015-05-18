module SpreeMultiCurrency
  class GetRates
    def self.call(in_currency, currencies)
      new.call(in_currency, currencies)
    end

    def call(in_currency, currencies)
      currencies.each_with_object({}) do |to_currency, rates|
        doc = Net::HTTP.get('www.google.com', "/finance/converter?a=1&from=#{in_currency}&to=#{to_currency}")
        regexp = Regexp.new("(\\d+\\.{0,1}\\d*)\\s+#{to_currency}")
        regexp.match doc
        rates[to_currency] = $1.to_f
      end
    end
  end
end

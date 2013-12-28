class Cryptotrade
  include Exchange

  def update
    @data = {}
    @currency_pairs =[
      ["BTC", "USD"],
      ["BTC", "EUR"],
      ["LTC", "USD"],
      ["LTC", "EUR"],
      ["LTC", "BTC"],
      ["NMC", "USD"],
      ["NMC", "BTC"],
      ["XPM", "USD"],
      ["XPM", "BTC"],
      ["XPM", "PPC"],
      ["PPC", "USD"],
      ["PPC", "BTC"],
      ["TRC", "BTC"],
      ["FTC", "USD"],
      ["FTC", "BTC"],
      ["DVC", "BTC"],
      ["WDC", "BTC"],
      ["DGC", "BTC"]
    ]
    @currency_pairs.each do |pair|
      url = "https://crypto-trade.com/api/1/depth/#{pair[0].downcase}_#{pair[1].downcase}"
      @data[pair] = JSON.load(open(url))
    end
  end

  def bids(pair)
    return if @data[pair].nil?
    Enumerator.new do |enum|
      @data[pair]["bids"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    return if @data[pair].nil?
    Enumerator.new do |enum|
      @data[pair]["asks"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end
end

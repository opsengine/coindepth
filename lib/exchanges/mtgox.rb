class Mtgox
  include Exchange

  def update
    @data = {}
    @currency_pairs = [
      ["BTC", "USD"],
      ["BTC", "GBP"],
      ["BTC", "EUR"]
    ]
    @currency_pairs.each do |pair|
      url = "http://data.mtgox.com/api/2/#{pair[0]}#{pair[1]}/money/depth/fetch"
      @data[pair] = JSON.load(open(url))
    end
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["data"]["bids"].reverse.each do |order|
        price = order["price"].to_f
        amount = order["amount"].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["data"]["asks"].each do |order|
        price = order["price"].to_f
        amount = order["amount"].to_f
        enum.yield price, amount
      end
    end
  end

end

class Rocktrading
  include Exchange

  def update
    @data = {}
    @currency_pairs =[
      ["BTC", "EUR"],
      ["BTC", "USD"],
      ["BTC", "XRP"],
      ["EUR", "XRP"],
      ["LTC", "BTC"],
      ["LTC", "EUR"]
    ]
    @currency_pairs.each do |pair|
      url = "https://www.therocktrading.com/api/orderbook/#{pair[0]}#{pair[1]}"
      @data[pair] = JSON.load(open(url))
    end
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["bids"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["asks"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end
end

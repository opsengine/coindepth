class Btcmarkets
  include Exchange

  def update
    @data = {}
    @currency_pairs =[
      ["BTC", "AUD"],
      ["LTC", "AUD"]
    ]
    @currency_pairs.each do |pair|
      url = "https://api.btcmarkets.net/market/#{pair[0]}/#{pair[1]}/orderbook"
      @data[pair] = JSON.load(open(url))
    end
  end

  def bids(pair)
    return if @data[pair].nil?
    Enumerator.new do |enum|
      @data[pair]["bids"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    return if @data[pair].nil?
    Enumerator.new do |enum|
      @data[pair]["asks"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end
end

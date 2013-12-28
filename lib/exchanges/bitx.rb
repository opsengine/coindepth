class Bitx
  include Exchange

  def update
    @data = {}
    @currency_pairs =[
      ["BTC", "ZAR"]
    ]
    @currency_pairs.each do |pair|
      url = "https://bitx.co.za/api/1/#{pair[0]}#{pair[1]}/orderbook"
      @data[pair] = JSON.load(open(url))
    end
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["bids"].each do |order|
        price = order["price"].to_f
        amount = order["volume"].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["asks"].each do |order|
        price = order["price"].to_f
        amount = order["volume"].to_f
        enum.yield price, amount
      end
    end
  end

end

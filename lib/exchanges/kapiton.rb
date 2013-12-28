class Kapiton
  include Exchange

  def update
    @currency_pairs = [
      ["BTC", "SEK"]
    ]
    url = "https://kapiton.se/api/0/orderbook"
    @data = { @currency_pairs.first => JSON.load(open(url)) }
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

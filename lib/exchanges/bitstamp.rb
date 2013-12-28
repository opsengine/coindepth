class Bitstamp
  include Exchange

  def update
    @currency_pairs = [
      ["BTC", "USD"]
    ]
    url = "https://www.bitstamp.net/api/order_book/?group=1"
    @data = { @currency_pairs.first => JSON.load(open(url)) }
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["bids"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["asks"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

end

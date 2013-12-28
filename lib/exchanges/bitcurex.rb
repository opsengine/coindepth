class Bitcurex
  include Exchange

  def update
    @currency_pairs = [
      ["BTC", "PLN"]
    ]
    url = "https://pln.bitcurex.com/data/orderbook.json"
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

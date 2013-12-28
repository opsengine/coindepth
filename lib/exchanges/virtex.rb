class Virtex
  include Exchange

  def update
    @currency_pairs = [
      ["BTC", "CAD"]
    ]
    url = "https://www.cavirtex.com/api/CAD/orderbook.json"
    @data = { @currency_pairs.first => JSON.load(open(url)) }
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["bids"].sort.reverse.each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["asks"].sort.each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

end

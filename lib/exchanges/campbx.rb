class Campbx
  include Exchange

  def update
    @currency_pairs = [
      ["BTC", "USD"]
    ]
    url = "http://campbx.com/api/xdepth.php"
    @data = { @currency_pairs.first => JSON.load(open(url)) }
  end

  def bids(pair)
    Enumerator.new do |enum|
      @data[pair]["Bids"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      @data[pair]["Asks"].each do |order|
        price = order[0].to_f
        amount = order[1].to_f
        enum.yield price, amount
      end
    end
  end

end

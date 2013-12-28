class Cryptsy
  include Exchange

  def update
    @currency_pairs = []
    @market_id = {}
    @depth = {}
    @data = JSON.load(open("http://pubapi.cryptsy.com/api.php?method=orderdata"))
    @data["return"].values.map do |market|
      pair = [market["primarycode"], market["secondarycode"]]
      @market_id[pair] = market["marketid"]
      @currency_pairs << pair
      @depth[pair] = market
    end
  end

  def bids(pair)
    market = @depth[pair]
    return if market["buyorders"].nil?
    Enumerator.new do |enum|
      market["buyorders"].each do |order|
        price = order["price"].to_f
        amount = order["quantity"].to_f
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    market = @depth[pair]
    return if market["sellorders"].nil?
    Enumerator.new do |enum|
      market["sellorders"].each do |order|
        price = order["price"].to_f
        amount = order["quantity"].to_f
        enum.yield price, amount
      end
    end
  end

end

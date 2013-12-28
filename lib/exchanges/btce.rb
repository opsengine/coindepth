class Btce
  include Exchange

  def update
    info = JSON.load(open("https://btc-e.com/api/3/info"))
    @currency_pairs = []
    info["pairs"].keys.each do |pair|
      cur1 = pair.split("_")[0].upcase
      cur2 = pair.split("_")[1].upcase
      @currency_pairs << [cur1, cur2]
    end
    limit = 300
    ignore_invalid = 1
    pairs = info['pairs'].keys.join('-')
    url = "https://btc-e.com/api/3/depth/#{pairs}?limit=#{limit}&ignore_invalid=#{ignore_invalid}"
    @data = JSON.load(open(url).read)
  end

  def bids(pair)
    Enumerator.new do |enum|
      market = @data["#{pair[0].downcase}_#{pair[1].downcase}"]
      market["bids"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end

  def asks(pair)
    Enumerator.new do |enum|
      market = @data["#{pair[0].downcase}_#{pair[1].downcase}"]
      market["asks"].each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end

end

class Okcoin
  include Exchange

  def update
    @data = {}
    @currency_pairs =[
      ["BTC", "CNY"],
      ["LTC", "CNY"]
    ]
    @currency_pairs.each do |pair|
      url = "https://www.okcoin.com/api/depth.do?symbol=#{pair[0].downcase}/#{pair[1].downcase}"
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
      @data[pair]["asks"].reverse.each do |order|
        price = order[0]
        amount = order[1]
        enum.yield price, amount
      end
    end
  end

end

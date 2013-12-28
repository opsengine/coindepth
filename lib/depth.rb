class MarketDepth

  attr_accessor :mid_price, :bids, :asks, :total_asks, :total_bids, :name, :range, :min_price, :max_price

  def initialize
    @bids = {}
    @asks = {}
    @range = 20
  end

  def get_asks_series
    series = "["
    @asks.map do |price, amount|
      next if price > @max_price
      series += "[#{price},#{amount}],"
    end
    series += "]"
  end

  def get_bids_series
    series = "["
    @bids.map do |price, amount|
      next if price < @min_price
      series += "[#{price},#{amount}],"
    end
    series += "]"
  end

  def calc_stats
    lowest_ask = @asks.first[0]
    highest_bid = @bids.first[0]
    @mid_price = (lowest_ask + highest_bid) / 2
    @min_price = highest_bid / (1 + @range/100.0)
    @max_price = lowest_ask * (1 + @range/100.0)
  end
end

module Exchange
  attr_accessor :currency_pairs

  def initialize
    @currency_pairs = []
  end

  def get_depth(pair)
    depth = MarketDepth.new
    total_bids = 0
    if not bids(pair).nil?
      bids(pair).each do |price, amount|
        total_bids += amount
        depth.bids[price] = total_bids
      end
    end
    depth.total_bids = total_bids
    total_asks = 0
    if not asks(pair).nil?
      asks(pair).each do |price, amount|
        total_asks += amount
        depth.asks[price] = total_asks
      end
    end
    depth.total_asks = total_asks
    depth.calc_stats
    return depth
  end
end

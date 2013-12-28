require 'sinatra'
require 'net/http'
require 'json'
require 'open-uri'
require 'timers'

class Fixnum
  def signif(signs)
    return self
  end
end

class Float
  def signif(signs)
    Float("%.#{signs}g" % self)
  end
end

class ExchangeCache

  def initialize
    @exchanges = {}
    Dir[File.dirname(__FILE__) + "/lib/depth.rb"].each {|file| require file}
    Dir[File.dirname(__FILE__) + "/lib/exchanges/*.rb"].each { |file|
      require file
      name = File.basename(file).split(".")[0]
      @exchanges[name] = create_client(name)
      puts "Loaded exchange #{name}"
    }
  end

  def create_client(name)
    class_name = name.capitalize
    cls = Module.const_get(class_name)
    return cls.new
  end

  def start
    Thread.new do
      @timer = Timers.new
      @exchanges.map do |name, exchange|
        @timer.every(5) {
          begin
            puts "Updating exchange #{name}..."
            new_exchange = create_client(name)
            new_exchange.update
            @exchanges[name] = new_exchange
          rescue => e
            puts e
          end
        }
      end
      loop { @timer.wait }
    end
  end

  def stop
    @timer.reset
  end

  def list_exchanges
    return @exchanges.keys
  end

  def list_currency_pairs
    pairs = Set.new
    @exchanges.map do |name, exchange|
      exchange.currency_pairs.each do |pair|
        pairs.add pair
      end
    end
    return pairs.to_a
  end

  def search(exchange_name=nil, pair=nil)
    if exchange_name.nil?
      exchanges = @exchanges.keys
    else
      exchanges = [exchange_name]
    end
    data = {}
    exchanges.each do |exchange_name|
      next if not @exchanges.has_key? exchange_name
      exchange = @exchanges[exchange_name]
      exchange_data = []
      if pair.nil?
        pairs = exchange.currency_pairs
      else
        pairs = [pair]
      end
      pairs.each do |pair|
        exchange_data << pair
      end
      data[exchange_name] = exchange_data
    end
    return data
  end

  def get_depth(exchange_name=nil, pair=nil)
    range = 40
    significant_digits = 3
    if exchange_name.nil?
      exchanges = @exchanges.keys
    else
      exchanges = [exchange_name]
    end
    data = {}
    exchanges.each do |exchange_name|
      next if not @exchanges.has_key? exchange_name
      exchange = @exchanges[exchange_name]
      exchange_data = {}
      if pair.nil?
        pairs = exchange.currency_pairs
      else
        pairs = [pair]
      end
      pairs.each do |pair|
        pair_label = "#{pair[0]}/#{pair[1]}"
        begin
          depth = exchange.get_depth(pair)
          min_price = depth.bids.first[0] * (1 - range / 100.0)
          max_price = depth.asks.first[0] * (1 + range / 100.0)
          exchange_data[pair_label] = {}
          exchange_data[pair_label]["bids"] = []
          depth.bids.each do |price, amount|
            break if price < min_price
            exchange_data[pair_label]["bids"] << [price, amount.signif(significant_digits)]
          end
          exchange_data[pair_label]["asks"] = []
          depth.asks.each do |price, amount|
            break if price > max_price
            exchange_data[pair_label]["asks"] << [price, amount.signif(significant_digits)]
          end
          exchange_data[pair_label]["min_price"] = min_price
          exchange_data[pair_label]["max_price"] = max_price
        rescue => e
          puts e
          puts caller
        end
      end
      data[exchange_name] = exchange_data
    end
    return data
  end

end

ec = ExchangeCache.new
ec.start

get '/exchanges' do
  ec.list_exchanges.to_json
end

get '/markets' do
  ec.list_currency_pairs.to_json
end

get '/depth' do
  data = ec.get_depth
  if data == {}
    status 404
    body 'Data not found'
    return
  end
  data.to_json
end

get '/depth/:exchange' do
  data = ec.get_depth(params["exchange"])
  if data == {}
    status 404
    body 'Data not found'
    return
  end
  data.to_json
end

get '/depth/:exchange/:cur1/:cur2' do
  cur1 = params["cur1"].upcase
  cur2 = params["cur2"].upcase
  data = ec.get_depth(params["exchange"], [cur1, cur2])
  if data == {}
    status 404
    body 'Data not found'
    return
  end
  data.to_json
end

get '/search' do
  data = ec.search
  if data == {}
    status 404
    body 'Data not found'
    return
  end
  data.to_json
end

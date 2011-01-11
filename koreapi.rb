require 'net/http'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics
  BALBOA = "balboa.sea1.socrata.com" 
  PORT = 9898 

  def __query(url)
    service = Net::HTTP.new(BALBOA, PORT)
    puts "requesting -> #{url}" 
    request = Net::HTTP::Get.new(url)
    result = service.request(request)
    return result.body 
  end

  def __get(entity, options)
    return __query("/metrics/#{entity}?#{options.to_params}")
  end

  def __range(entity, options)
    return __query("/metrics/#{entity}/range?#{options.to_params}")
  end

  def __series(entity, options)
    return __query("/metrics/#{entity}/series?#{options.to_params}")
  end

  def get(entity, date, type)
    return __get(entity, {"date" => date, "type" => type})
  end

  def range(entity, start, finish)
    return __range(entity, {"start" => start, "end" => finish})
  end

  def series(entity, start, finish, type)
    return __series(entity, {"start" => start, "end" => finish, "series" => type})
  end
end

require 'sinatra/base'
class KoreaPI < Sinatra::Base
  set :public, File.dirname(__FILE__) + '/public'

  get "/?" do 
    erb :index 
  end

  get "/q/:entity" do
    params.delete("_")
    entity = params.delete("entity")
    puts params.inspect
    puts entity
    Metrics.new.__get(entity, params)
  end

  get "/q/:entity/range" do
    params.delete("_")
    entity = params.delete("entity")
    puts params.inspect
    puts entity
    Metrics.new.__range(entity, params)
  end

  get "/q/:entity/series" do
    params.delete("_")
    entity = params.delete("entity")
    puts params.inspect
    puts entity
    Metrics.new.__series(entity, params)
  end
end 


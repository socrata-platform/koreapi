require 'net/http'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics
  BALBOA = "balboa.sea1.socrata.com"
  PORT = 9999

  def __query(entity, options)
    service = Net::HTTP.new(BALBOA, PORT)
    puts "requesting -> /#{entity}?#{options.to_params}"
    request = Net::HTTP::Get.new("/#{entity}?#{options.to_params}")
    result = service.request(request)
    return result.body 
  end

  def get(entity, date, type)
    return __query(entity, {"date" => date, "type" => type})
  end

  def range(entity, start, finish)
    return __query(entity, {"start" => start, "end" => finish, "range" => "t"})
  end

  def series(entity, start, finish, type)
    return __query(entity, {"start" => start, "end" => finish, "series" => type})
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
    Metrics.new.__query(entity, params)
  end
end 



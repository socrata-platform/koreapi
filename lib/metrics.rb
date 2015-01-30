require 'net/http'
require 'sinatra/base'
require_relative '../helpers/config_utils'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics

  BALBOA_ADDRESS = Sinatra::KoreaPI::ConfigUtils.get_first_attr('metric-config.balboa.server')

  def initialize
    addr_port = BALBOA_ADDRESS.split(':')
    @service = Net::HTTP.new(addr_port[0], addr_port[1])
    @service.open_timeout=10000
    @service.read_timeout=30
  end

  def get(entity, date, type)
    return __get(entity, {"date" => date, "type" => type})
  end

  def range(entity, start, finish)
    return __range(entity, {"start" => start, "end" => finish})
  end

  def series(entity, start, finish, type)
    return __series(entity, {"start" => start, "end" => finish, "period" => type})
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

  private

  def __query(url)
    puts "requesting -> #{url}"
    request = Net::HTTP::Get.new(url)
    result = @service.request(request)
    puts "  -> done"
    return result.body
  end

end

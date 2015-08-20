require 'net/http'
require 'sinatra/base'
require_relative '../helpers/config_utils'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics

  BALBOA_HOST = Sinatra::KoreaPI::ConfigUtils.get_first_attr('metric-config.balboa.server.host')
  BALBOA_PORT = Sinatra::KoreaPI::ConfigUtils.get_first_attr('metric-config.balboa.server.port', 2012)

  def initialize
    @service = Net::HTTP.new(BALBOA_HOST, BALBOA_PORT)
    @service.open_timeout=10000
    @service.read_timeout=30
  end

  def get(entity, date, type)
    return __get(entity, {"date" => date, "type" => type})
  end

  def range(entity, start, finish)
    return __range(entity, {"start" => start, "end" => finish})
  end

  # Wraps a series metrics method call
  #
  # @param - entity The entity ID to find metrics for
  # @param - start The Start Date Time
  # @param - start finish The end of the series window
  # @param - type The interval type to find metrics for.
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

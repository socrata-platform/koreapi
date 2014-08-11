require 'net/http'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics
  def initialize
    @service = Net::HTTP.new(BALBOA, PORT)
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

  BALBOA = "lb-vip.sea1.socrata.com"
  PORT = 9898

  def __query(url)
    puts "requesting -> #{url}"
    request = Net::HTTP::Get.new(url)
    result = @service.request(request)
    puts "  -> done"
    return result.body
  end

end

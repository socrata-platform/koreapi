require 'net/http'
require 'sinatra/base'
require_relative '../helpers/config_utils'

class Domains
  CORE_HOST = Sinatra::KoreaPI::ConfigUtils.get_first_attr('core.server.host')
  CORE_PORT = Sinatra::KoreaPI::ConfigUtils.get_first_attr('core.server.port', 8081)

  def get_domains
    service = Net::HTTP.new(CORE_HOST, CORE_PORT)
    url = '/domains?method=all'
    request = Net::HTTP::Get.new(url)
    result = service.request(request)
    domain_data = JSON.parse(result.body)
    domains = {}
    domain_data.each { |d|
      domains[d['cname']] = d['id']
    }
    domains
  end

end

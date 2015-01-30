require 'net/http'
require 'sinatra/base'
require_relative '../helpers/config_utils'

class Domains

  CORE_ADDRESS = Sinatra::KoreaPI::ConfigUtils.get_first_attr('core.server')

  def get_domains

    addr_port = CORE_ADDRESS.split(":")
    service = Net::HTTP.new(addr_port[0], addr_port[1])
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

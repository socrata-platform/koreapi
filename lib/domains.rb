require 'net/http'
require 'sinatra/base'
require_relative '../helpers/config_utils'

class Domains

  CORE_ADDRESS = Sinatra::KoreaPI::ConfigUtils.get_first_attr('core.server')

  def get_domains

    address_and_port = CORE_ADDRESS.split(':')
    service = Net::HTTP.new(address_and_port[0], address_and_port[1].to_i)
    url = 'domains?method=all'
    request = Net::HTTP::Get.new(url)
    # result = service.request(request)
    result = service.request(request)
    domain_data = JSON.parse(result.body)
    domains = {}
    domain_data.each { |d|
      domains[d['cname']] = d['id']
    }
    domains
  end

end

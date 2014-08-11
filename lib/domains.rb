require 'net/http'

class Domains
  CORE = "lb-vip.sea1.socrata.com"
  CORE_PORT = 8081

  def get_domains()
    service = Net::HTTP.new(CORE, CORE_PORT)
    url = "/domains?method=all"
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

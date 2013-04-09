require 'net/http'
require 'v8'
require 'json'

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

class ScriptMetaData
  attr_accessor :content_type
  attr_accessor :filename
  attr_accessor :errors

  def log(string)
    puts(string)
  end


end

require 'sinatra/base'
class KoreaPI < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public_folder'

  def initialize()
    super()
    script_path = "scriptlets"
    @scriptlets = {}
    Dir.foreach(script_path) do |f|
      unless f =~ /\.js$/
        next
      end
      name = f.sub(/.js/, '')
      path = script_path + "/" + f
      @scriptlets[name] = path
      puts ("Got " + name + " => " + path)
    end
    @domains = Domains.new().get_domains();
    puts "Loaded domains #{@domains}"
  end

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

  get "/domains" do
    @domains.to_json
  end

  get "/scriptlets" do
    @scriptlets.to_json
  end

  get "/scriptlets/:name/info" do
    metaData = ScriptMetaData.new
    cxt = V8::Context.new
    cxt['scriptlet'] = metaData
    cxt.load(@scriptlets[params["name"]])
    out = cxt.eval('info()')
    out
  end

  get "/scriptlet/:name" do
    content_type 'text/html'
    params.delete("_")
    cxt = V8::Context.new
    metaData = ScriptMetaData.new
    cxt['m'] = Metrics.new
    cxt['scriptlet'] = metaData
    cxt['domains'] = @domains || {}

    cxt.load(@scriptlets[params["name"]])
    info = JSON.parse(cxt.eval('info()'))
    info['params'].each { |p|
      if p[0] == "domain_id"
        cxt['domain_id'] = @domains[params[p[0]]]
      else
        cxt[p[0]] = params[p[0]]
      end
    }

    out = cxt.eval('run()').to_s
    if !metaData.errors.nil?
      content_type ( metaData.content_type || "text/html" )
      return metaData.errors
    end

    content_type ( metaData.content_type || "applicaton/json" )
    attachment (metaData.filename || params["name"])
    out
  end

end 

KoreaPI.run!

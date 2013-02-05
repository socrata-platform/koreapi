require 'net/http'
require 'v8'
require 'json'

class Hash
  def to_params
    self.collect { |k, v| "#{k}=#{v}" }.join '&'
  end
end

class Metrics

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

  def age(file)
    age = Time.now - File.mtime(file)
    (age / 24*60*60).to_i
  end

  def __query(url)
    service = Net::HTTP.new(BALBOA, PORT)
    service.read_timeout = 120000
    service.open_timeout = 120000
    puts "requesting -> #{url}"
    request = Net::HTTP::Get.new(url)
    result = service.request(request)
    return result.body
  end


end

class ScriptMetaData
  attr_accessor :content_type
  attr_accessor :errors

  def log(string)
    puts(string)
  end


end

require 'sinatra/base'
class KoreaPI < Sinatra::Base
  set :public, File.dirname(__FILE__) + '/public'

  def initialize()
    super()
    script_path = "scriptlets"
    @scriptlets = {}
    Dir.foreach(script_path) do |f|
      if f =~ /^\./
        next
      end
      name = f.sub(/.js/, '')
      path = script_path + "/" + f
      @scriptlets[name] = path
      puts ("Got " + name + " => " + path)
    end
    @domains = JSON.parse(IO.read("domains.json"))
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

  get "/scriptlets" do
    @scriptlets.to_json
  end

  get "/scriptlet/:name" do
    content_type 'text/html'
    params.delete("_")
    cxt = V8::Context.new
    metaData = ScriptMetaData.new
    cxt['m'] = Metrics.new
    cxt['meta'] = metaData
    cxt['start'] = params["start"]
    cxt['end'] = params["end"]
    cxt['entity'] = params["entity"]
    cxt['period'] = params["period"]
    cxt['domains'] = @domains || {}

    out = cxt.load(@scriptlets[params["name"]]).to_s
    if !metaData.errors.nil?
      content_type ( metaData.content_type || "text/html" )
      return metaData.errors
    end

    content_type ( metaData.content_type || "applicaton/json" )
    out
  end

end 

KoreaPI.run!

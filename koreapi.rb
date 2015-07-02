require 'v8'
require 'json'
require 'sinatra/base'
require 'parseconfig'
require 'tempfile'
require 'logger'

if $log.nil?
  $log = Logger.new(STDOUT)
  $log.level = Logger::DEBUG
end

require_relative 'helpers/param_utils'
require_relative 'helpers/s3_utils'
require_relative 'lib/metrics'
require_relative 'lib/domains'
require_relative 'lib/script_metadata'

class KoreaPI < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public_folder'

  helpers Sinatra::KoreaPI::ParamUtils
  helpers Sinatra::KoreaPI::S3Utils

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
    params.delete("_")
    cxt = V8::Context.new
    metaData = ScriptMetaData.new
    tempFile = Tempfile.new('koreapi-tmp-metrics', '/tmp/')
    cxt['m'] = Metrics.new
    cxt['scriptlet'] = metaData
    cxt['domains'] = @domains || {}
    cxt['tempFile'] = tempFile
    load_into_context(cxt, params)
    if !metaData.errors.nil?
      content_type "text/html"
      return metaData.errors
    end

    File.open("js/underscore-min.js") do |file|
        cxt.eval(file, "js/underscore-min.js")
    end

    File.open("js/csv/csv.js") do |file|
        cxt.eval(file, "js/csv/csv.js")
    end

    cxt.eval('runAndWriteToFile()')
    if !metaData.errors.nil?
      content_type ( metaData.content_type || "text/html" )
      return metaData.errors
    end
    tempFile.flush

    if params['push_to_s3'] == 'true'
      bucket = cxt['s3_bucket']
      unless bucket.nil?
        config = ParseConfig.new('/etc/koreapi.properties')
        destinationFile = "domain_report.csv"
        content_type "text/html"
        return push_to_s3(bucket, tempFile.path, destinationFile)
      end
    end
    send_file(tempFile, :disposition => 'attachment', :filename => "#{params["name"]}.csv")
    tempFile.delete
  end

end

KoreaPI.run!

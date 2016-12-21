require 'rack/body_proxy'

class LoggingMiddleware
  def initialize(app, logger)
    @app = app
    @logger = (logger || Logger.new(STDOUT)).tap do |log_obj|
      log_obj.datetime_format = '%Y-%m-%d %H:%M:%S,%L '
    end
  end

  def call(env)
    began_at = Time.now
    status, header, body = @app.call(env)
    header = Rack::Utils::HeaderHash.new(header)
    body = Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
    [status, header, body]
  end

  private
  def log(env, status, header, began_at)
    fields_to_display = 
      {
        method: env[Rack::REQUEST_METHOD],
        path: env[Rack::PATH_INFO],
        status: status.to_s[0..3],
        duration: Time.now - began_at
      }.map { |(key, value)| "#{key}=#{value}" }.join(' ')

    @logger.info(fields_to_display)
  end
end

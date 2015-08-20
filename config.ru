require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require


$stdout.puts('Redirecting output to log/sinatra.log')
FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")

$stdout.reopen(log)
$stderr.reopen(log)
$log = Logger.new(log)
$log.level = Logger::ERROR

require './koreapi'

run KoreaPI

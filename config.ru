require 'rubygems'
require 'bundler'

Bundler.require

require './koreapi'

root_dir = File.dirname(__FILE__)

$stdout.puts("Redirecting output to log/sinatra.log")
FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

run KoreaPI

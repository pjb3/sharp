require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development)

Sharp.boot(File.expand_path('../..', __FILE__))

require 'rubygems'
require 'bundler'

Bundler.require
loader = Zeitwerk::Loader.new
loader.push_dir('./app/routes')
loader.setup

require_relative './app'
run App

require 'rubygems'
require 'bundler'
require 'dotenv/load'

Bundler.require
loader = Zeitwerk::Loader.new
loader.push_dir('./app/interactors')
loader.push_dir('./app/routes')
loader.push_dir('./app/services')
loader.setup

require_relative './app'
run App

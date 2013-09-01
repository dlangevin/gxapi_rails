require 'active_support'
require 'celluloid'
require 'erb'
require 'json'
require 'yaml'

require File.expand_path('../moona/base', __FILE__)
require File.expand_path('../moona/google_analytics', __FILE__)
require File.expand_path('../moona/ostruct', __FILE__)


if defined?(::Rails)
  require File.expand_path('../moona/engine', __FILE__)
end

module Moona

  public

  # get our cache instance
  # @return ActiveSupport::Cache::Store
  def self.cache
    # if we have an overridden cache, return it
    return @overridden_cache if defined?(@overridden_cache)
    # use Rails.cache if it is defined
    return ::Rails.cache if defined?(::Rails) && ::Rails.cache
    # last resort, just use our own cache choice
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  # setter for {Moona.cache}
  def self.cache=(cache)
    @overridden_cache = cache
  end

  # namespace for our cache keys
  # @return [String, nil]
  def self.cache_namespace
    @cache_namespace
  end

  # setter for {Moona.cache_namespace}
  def self.cache_namespace=(val)
    @cache_namespace = val
  end

  # Moona config - this is loaded based on the
  # {Moona.config_path}
  # @return Moona::Ostruct
  def self.config
    @config ||= begin
      # parse our yml file after running it through ERB
      contents = File.read(self.config_path)
      yml = ERB.new(contents).result(binding)
      Moona::Ostruct.new(YAML.load(yml)[Moona.env])
    end
  end

  # get the config path for our config YAML file
  # @return String defaults to #{Rails.root}/config/moona.yml
  def self.config_path
    @config_path ||= File.join(Rails.root, "config/moona.yml")
  end

  # setter for config path
  # @return String value of {Moona.config_path}
  def self.config_path=(val)
    @config_path = val
  end

  # our environment - defaults to Rails.env or test
  def self.env
    @env ||= defined?(::Rails) ? ::Rails.env : "test"
  end

  # Set the value of {Moona.env}
  # @return String environment
  def self.env=(val)
    @env = val
  end

  # instance of logger for Moona
  # @return [Logger, Log4r::Logger]
  def self.logger
    return ::Rails.logger if defined?(::Rails) && ::Rails.logger
    @logger ||= Logger.new(STDOUT)
  end

  # root directory for moona
  # @return String
  def self.root
    File.expand_path("../../", __FILE__)
  end

  # wrap with error handling
  # logs errors and returns false if an error
  # occurs
  # @return [Value, false]
  def self.with_error_handling(&block)
    begin
      yield
    rescue => e
      self.logger.error(e.message)
      self.logger.error(e.backtrace)
      false
    end
  end
end
require 'active_support'
require 'celluloid'
require 'erb'
require 'json'
require 'yaml'

require File.expand_path('../gxapi/base', __FILE__)
require File.expand_path('../gxapi/google_analytics', __FILE__)
require File.expand_path('../gxapi/ostruct', __FILE__)
require File.expand_path('../gxapi/version', __FILE__)


if defined?(::Rails)
  require File.expand_path('../gxapi/controller_methods', __FILE__)
  require File.expand_path('../gxapi/engine', __FILE__)
end

module Gxapi

  #
  # get our cache instance
  #
  # @return [ActiveSupport::Cache::Store]
  def self.cache
    # if we have an overridden cache, return it
    return @overridden_cache if defined?(@overridden_cache)
    # use Rails.cache if it is defined
    return ::Rails.cache if defined?(::Rails) && ::Rails.cache
    # last resort, just use our own cache choice
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  #
  # setter for {Gxapi.cache}
  #
  # @return [ActiveSupport::Cache::Store] The new cache object
  def self.cache=(cache)
    @overridden_cache = cache
  end

  #
  # namespace for our cache keys
  #
  # @return [String, nil]
  def self.cache_namespace
    @cache_namespace
  end

  #
  # setter for {Gxapi.cache_namespace}
  #
  # @return [String] New value for cache_namespace
  def self.cache_namespace=(val)
    @cache_namespace = val
  end

  #
  # Gxapi config - this is loaded based on the
  # {Gxapi.config_path}
  #
  # @return [Gxapi::Ostruct]
  def self.config
    @config ||= begin
      # parse our yml file after running it through ERB
      contents = File.read(self.config_path)
      yml = ERB.new(contents).result(binding)
      Gxapi::Ostruct.new(YAML.load(yml)[Gxapi.env])
    end
  end

  #
  # manual setter for for config settings
  #
  # @return [Gxapi::Ostruct]
  def self.config=(settings={})
    @config = Gxapi::Ostruct.new(settings)
  end

  #
  # get the config path for our config YAML file
  #
  # @return [String] defaults to #{Rails.root}/config/gxapi.yml
  def self.config_path
    @config_path ||= File.join(Rails.root, "config/gxapi.yml")
  end

  #
  # setter for config path
  #
  # @return [String] value of {Gxapi.config_path}
  def self.config_path=(val)
    @config_path = val
  end

  #
  # our environment - defaults to Rails.env or test
  #
  # @return [String]
  def self.env
    @env ||= defined?(::Rails) ? ::Rails.env : "test"
  end

  #
  # Set the value of {Gxapi.env}
  #
  # @return [String] environment
  def self.env=(val)
    @env = val
  end

  #
  # instance of logger for Gxapi
  #
  # @return [Logger, Log4r::Logger]
  def self.logger
    @logger ||= begin
      if defined?(::Rails) && ::Rails.logger
        ::Rails.logger
      else
        Logger.new(STDOUT)
      end
    end
  end


  #
  # Setter for the Logger
  # @param  logger [Logger, Log4r]
  #
  # @return [Logger, Log4r] Logger instance
  def self.logger=(logger)
    @logger = logger
  end

  #
  # Reload all data from experiments
  #
  # @return [Boolean] Always true
  def self.reload_experiments
    Base.new("").reload_experiments
    true
  end


  #
  # root directory for gxapi
  #
  # @return [String]
  def self.root
    File.expand_path("../../", __FILE__)
  end

  #
  # Wrap with error handling
  # logs errors and returns false if an error
  # occurs
  #
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
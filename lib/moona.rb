require 'active_support'
require 'celluloid'
require 'json'
require 'rest_client'
require 'yaml'

require File.expand_path('../moona/base', __FILE__)

module Moona

  public

  # get our cache
  def self.cache
    # if we have an overridden cache, return it
    return @overridden_cache if defined?(@overridden_cache)
    # use Rails.cache if it is defined
    return Rails.cache if defined?(Rails) && Rails.cache
    # last resort, just use our own cache choice
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  def self.cache=(cache)
    @overridden_cache = cache
  end

  def self.cache_namespace
    @cache_namespace
  end

  def self.cache_namespace=(val)
    @cache_namespace = val
  end

  # get the config path for our config YAML file
  def self.config_path
    @config_path ||= File.expand_path("../../config/moona.yml", __FILE__)
  end
  
  # setter for config path
  def self.config_path=(val)
    @config_path = val
  end
  
  # our environment - defaults to Rails.env or test
  def self.env
    @env ||= defined?(Rails) ? Rails.env : "test"
  end
  
  # set our env val
  def self.env=(val)
    @env = val
  end

  def self.get_all_experiments
    self.experiment_config[self.env].keys
  end

  def self.get_default_value_for_experiment(experiment_name)
    self.experiment_config["defaults"][experiment_name]
  end

  protected

  def self.experiment_config
    @experiment_config ||= begin
      YAML.load(File.read(self.config_path))
    end
  end

  # get the UUID for a valid experiment
  def self.experiment_uuid(experiment_name)
    self.experiment_config[self.env][experiment_name]
  end
  

end
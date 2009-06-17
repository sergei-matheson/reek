require 'reek/smells/control_couple'
require 'reek/smells/duplication'
require 'reek/smells/feature_envy'
require 'reek/smells/large_class'
require 'reek/smells/long_method'
require 'reek/smells/long_parameter_list'
require 'reek/smells/long_yield_list'
require 'reek/smells/nested_iterators'
require 'reek/smells/uncommunicative_name'
require 'reek/smells/utility_function'
require 'yaml'

class Hash
  def push_keys(hash)
    keys.each {|key| hash[key].adopt!(self[key]) }
  end

  def adopt!(other)
    other.keys.each do |key|
      ov = other[key]
      if Array === ov and has_key?(key)
        self[key] += ov
      else
        self[key] = ov
      end
    end
    self
  end
  
  def adopt(other)
    self.deep_copy.adopt!(other)
  end
  
  def deep_copy
    YAML::load(YAML::dump(self))
  end
end

module Reek
  class Sniffer

    SMELL_CLASSES = [
      Smells::ControlCouple,
      Smells::Duplication,
      Smells::FeatureEnvy,
      Smells::LargeClass,
      Smells::LongMethod,
      Smells::LongParameterList,
      Smells::LongYieldList,
      Smells::NestedIterators,
      Smells::UncommunicativeName,
      Smells::UtilityFunction,
    ]

    def initialize
      defaults_file = File.join(File.dirname(__FILE__), '..', '..', 'config', 'defaults.reek')
      @config = YAML.load_file(defaults_file)
      @detectors = nil
      @listeners = []
    end

    def configure_using(filename)
      path = File.expand_path(File.dirname(filename))
      all_reekfiles(path).each do |rfile|
        YAML.load_file(rfile).push_keys(@config)
      end
      self
    end

    def disable(smell)
      @config[smell].adopt!({Reek::Smells::SmellDetector::ENABLED_KEY => false})
    end

    def report_on(report)
      @listeners.each {|smell| smell.report_on(report)}
    end

    def examine(scope, type)
      listeners = smell_listeners[type]
      listeners.each {|smell| smell.examine(scope) } if listeners
    end

private

    def smell_listeners()
      unless @detectors
        @detectors = Hash.new {|hash,key| hash[key] = [] }
        SMELL_CLASSES.each { |smell| @listeners << smell.listen(@detectors, @config) }
      end
      @detectors
    end

    def all_reekfiles(path)
      return [] unless File.exist?(path)
      parent = File.dirname(path)
      return [] if path == parent
      all_reekfiles(parent) + Dir["#{path}/*.reek"]
    end
  end
end

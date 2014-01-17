module GxApi


  #
  # Wrapper class to handle experiment identifier types
  #
  # @example
  #   identifier = ExperimentIdentifer.new("name")
  #   identifier.value #=> "name"
  #   identifier.matches_experiment?(Experiment(name: 'name')) #=> true
  #
  #   identifier = ExperimentIdentifer.new(id: "id")
  #   identifier.value #=> "id"
  #   identifier.matches_experiment?(Experiment(id: 'id')) #=> true
  #
  class ExperimentIdentifier < BasicObject

    #
    # Constructor
    #
    # @param  val [String, Hash] Either a String name or a Hash with ID
    #
    def initialize(val)
      # handle a string
      if val.is_a?(::String)
        @proxy = NameExperimentIdentifier.new(val)
      # handle an ID
      elsif val.try(:[], :id)
        @proxy = IdExperimentIdentifier.new(val[:id])
      # error if we don't have anything valid
      else
        raise ArgumentError.new("#{val} is not a valid identifier type")
      end
    end

    protected

    #
    # Implementation of method_missing
    # sends to our proxy
    #
    # @param  m [Symbol] Method name
    # @param  *args [Array<Mixed>] Args passed
    # @param  &block [Proc, nil] Block passed
    #
    # @return [Mixed] Whatever @proxy does
    def method_missing(m, *args, &block)
      @proxy.send(m, *args, &block)
    end

    #
    # Reader for the proxy
    #
    # @return [GenericIdentifier]
    def proxy
      @proxy
    end

  end

  class GenericIdentifier

    # @!attribute value
    #   @return [Symbol] Value of this identifier
    attr_reader :value

    #
    # Constructor
    # @param  value [String] Value string
    #
    def initialize(value)
      @value = value.to_s
    end

    #
    # Turn our value into a cache key
    #
    # @return [String] Key for caching
    def to_key
      self.value.downcase.gsub(/[^\w\d]+/,'_')
    end

  end

  class IdExperimentIdentifier < GenericIdentifier

    #
    # Does the given experiment match the identifier by its ID
    # @param  experiment [Ostruct] Experiment to test
    #
    # @return [Boolean] Does it match?
    def matches_experiment?(experiment)
      self.value == experiment.try(:id)
    end

  end

  class NameExperimentIdentifier < GenericIdentifier

    #
    # Does the given experiment match the identifier by its name
    # @param  experiment [Ostruct] Experiment to test
    #
    # @return [Boolean] Does it match?
    def matches_experiment?(experiment)
      self.value == experiment.try(:name)
    end

  end

end
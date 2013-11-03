module Gxapi
  class Ostruct
    # recursive open struct
    def initialize(hash)

      @hash = {}

      self.send(:extend, self.generated_methods)
      hash.each_pair do |key, val|
        # set the key to an underscored verison of itself
        key = self.underscore(key)
        self.define_accessors(key)
        self.send("#{key}=", self.convert_value_to_ostruct(val))
      end
    end

    def to_hash
      ret = {}
      @hash.dup.each_pair do |key, val|
        ret[key] = self.convert_value_from_ostruct(val)
      end
      ret
    end

    protected
    # convert a value to a Ostruct (where necessary)
    def convert_value_to_ostruct(data)
      case data
      when Hash
        self.class.new(data)
      when Array
        data.collect{|val| self.convert_value_to_ostruct(val)}
      else
        data
      end
    end


    def convert_value_from_ostruct(data)
      case data
      when Ostruct
        data.to_hash
      when Array
        data.collect{|val| self.convert_value_from_ostruct(data)}
      else
        data
      end
    end

    # define accessors for an attribute
    def define_accessors(field)
      # add the generated method
      self.generated_methods.module_eval do
        define_method(field) do
          @hash[field]
        end
        define_method("#{field}=") do |val|
          @hash[field] = val
        end
      end
    end

    # module to hold generated methods
    def generated_methods
      @generated_methods ||= Module.new
    end

    # dynamically define getter and setter when an unknown setter is called
    def method_missing(meth, *args, &block)
      if meth.to_s =~ /=$/
        self.define_accessors(meth.to_s.gsub(/=$/,''))
        return self.send(meth, *args, &block)
      end
      super
    end

    # take a string an convert it from
    # camelCase to under_scored
    def underscore(string)
      string = string.to_s
      string = string[0].downcase + string[1..-1].gsub(/([A-Z])/,'_\1')
      string.downcase
    end

  end
end
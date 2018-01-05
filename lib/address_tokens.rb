require 'yaml'
require 'address_tokens/version'

module AddressTokens
  class Finder
    attr_accessor :states, :cities

    def initialize(str)
      raise Exception, 'String is null or empty' if str.strip.size < 1
      @states, @cities = {}, {}
    end

    def load(var, file)
      load_file(var, file)
    end

    private

    def load_file(var, file)
      raise IOError, "File #{file} was not found" if !File.exist?(file)
      data = YAML.load(File.read(file))
      raise TypeError, "File #{file} is not a valid YAML file" if !data.kind_of?(Hash)
      instance_variable_set("@#{var}", data)
    end
  end
end

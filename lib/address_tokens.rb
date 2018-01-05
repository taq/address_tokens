require 'yaml'
require 'address_tokens/version'

module AddressTokens
  class Finder
    attr_reader :states, :cities

    def initialize(str)
      raise Exception, 'String is null or empty' if str.strip.size < 1
    end

    def states=(file)
      load(file, 'states')
    end

    def cities=(file)
      load(file, 'cities')
    end

    private

    def load(file, var)
      raise IOError, "File #{file} was not found" if !File.exist?(file)
      data = YAML.load(File.read(file))
      raise TypeError, "File #{file} is not a valid YAML file" if !data.kind_of?(Hash)
      instance_variable_set("@#{var}", data)
    end
  end
end

require 'ostruct'

module Appium
  class Lint
    require_relative 'lint/base'
    require_relative 'lint/h1_invalid'
    require_relative 'lint/h1_present'
    require_relative 'lint/h2_invalid'
    require_relative 'lint/h456_invalid'
    require_relative 'lint/line_break_invalid'

    # OpenStruct.new data: '', lines: '', file: ''
    attr_reader :input

    def initialize
      @rules = [H1Invalid, H1Present, H2Invalid, H456Invalid, LineBreakInvalid]
    end

    def self.init_data opts={}, input
      raise 'Input must exist' unless input
      data = opts[:data]
      if data
        input.data  = data.freeze
        input.lines = data.split(/\r?\n/).freeze
        input.file  = nil
      else
        file = opts[:file]
        raise 'File path must be provided' unless file
        raise "File must exist and be readable #{file}" unless File.exist?(file) && File.readable?(file)
        file = File.expand_path(file)

        input.data  = File.read(file).freeze
        input.lines = data.split(/\r?\n/).freeze
        input.file  = file.freeze
      end

      input
    end

    def self.new_input opts
      input = OpenStruct.new(data: '', lines: '', file: '')
      self.init_data opts, input
    end

    def call opts={}
      @input = self.class.new_input opts

      all_warnings = []
      @rules.each do |rule|
        warnings = rule.new(@input).call
        all_warnings << warnings unless warnings.empty?
      end

      all_warnings
    end
  end
end
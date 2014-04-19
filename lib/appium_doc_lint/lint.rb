module Appium
  class Lint
    require_relative 'lint/base'
    require_relative 'lint/h1_invalid'
    require_relative 'lint/h1_present'
    require_relative 'lint/h2_invalid'
    require_relative 'lint/h456_invalid'
    require_relative 'lint/line_break_invalid'

    def initialize
      @rules = [H1Invalid, H1Present, H2Invalid, H456Invalid, LineBreakInvalid]
    end

    def init_data opts={}
      data = opts[:data]
      if data
        @data  = data.freeze
        @lines = data.split(/\r?\n/).freeze
        @file  = nil
      else
        file = opts[:file]
        raise 'File path must be provided' unless file
        raise "File must exist and be readable #{file}" unless File.exist?(file) && File.readable?(file)

        file   = File.expand_path(file)
        @data  = File.read(file).freeze
        @lines = @data.split(/\r?\n/).freeze
        @file  = file.freeze
      end
    end

    def call opts={}
      init_data opts

      all_warnings = []
      @rules.each { |rule| all_warnings << rule.new(data: @data).call }

      all_warnings
    end
  end
end
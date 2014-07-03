require 'ostruct'

module Appium
  class Lint
    require_relative 'lint/base'
    require_relative 'lint/ext_missing'
    require_relative 'lint/h2_multiple'
    require_relative 'lint/h2_missing'
    require_relative 'lint/h2_invalid'
    require_relative 'lint/h156_invalid'
    require_relative 'lint/line_break_invalid'

    # OpenStruct.new data: '', lines: '', file: ''
    attr_reader :input

    def initialize
      @rules = [ExtMissing, H2Missing, H2Multiple, H2Invalid, H156Invalid, LineBreakInvalid]
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
        raise 'File must not be a dir' if File.directory?(file)
        file = File.expand_path(file)

        input.data  = File.read(file).freeze
        input.lines = input.data.split(/\r?\n/).freeze
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

      all_warnings = {}
      @rules.each do |rule|
        warnings = rule.new(@input).call
        unless warnings.empty?
          all_warnings.merge!(warnings) do |key, old_val, new_val|
            # flatten to prevent { :a => [[1, 2], 2]}
            [old_val, new_val].flatten
          end
        end
      end

      return {} if all_warnings.empty?

      # sort by line number
      all_warnings = all_warnings.sort.to_h

      # wrap with file path if available
      input.file ? { input.file => all_warnings } : all_warnings
    end

    def glob dir_glob
      results = {}
      Dir.glob dir_glob do |markdown|
        next if File.directory?(markdown)
        markdown = File.expand_path markdown
        results.merge!(self.call(file: markdown))
      end
      # glob order is system dependent so sort the results.
      results.sort.to_h
    end

    # Format data into a report
    def report data
      return nil if data.nil? || data.empty?
      result = ''
      data.each do |file_name, analysis|
        rel_path = File.join('.', File.expand_path(file_name).sub(Dir.pwd, ''))
        result += "\n#{rel_path}\n"
        analysis.each do |line_number, warning|
          result += "  #{line_number}: #{warning.join(',')}\n"
        end
      end
      result.strip!

      result.empty? ? nil : result
    end
  end
end

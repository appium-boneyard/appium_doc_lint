module Appium
  class Lint
    class Base
      attr_reader :data, :lines, :file, :warnings
      # Appium::Lint::Base.new file: '/path/to/file'
      #
      # Appium::Lint::Base.new data: 'some **markdown**'
      def initialize opts={}
        @warnings = []
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

      def call
        raise NotImplementedError
      end
    end
  end
end

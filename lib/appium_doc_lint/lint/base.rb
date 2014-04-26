module Appium
  class Lint
    # noinspection RubyArgCount
    class Base
      attr_reader :input, :warnings
      # Appium::Lint::Base.new file: '/path/to/file'
      #
      # Appium::Lint::Base.new data: 'some **markdown**'
      def initialize opts
        @input    = opts.is_a?(OpenStruct) ? opts : Appium::Lint.new_input(opts)
        @warnings = Hash.new []
      end

      # Record a warning on a zero indexed line number
      #
      # @param line_number [int] line number to warn on
      # @return [warnings]
      def warn line_number, extra=nil
        message = extra ? fail + ' ' + extra : fail
        warnings[line_number + 1] += [message]
        warnings
      end

      def fail
        raise NotImplementedError
      end

      def call
        raise NotImplementedError
      end
    end
  end
end

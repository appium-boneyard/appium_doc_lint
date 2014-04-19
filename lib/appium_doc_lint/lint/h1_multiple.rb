module Appium
  class Lint
    ###
    # Each doc must have exactly 1 h1
    class H1Multiple < Base
      def call
        h1_count = 0
        input.lines.each_with_index do |line, index|
          h1_detected = !! line.match(/^#[^#]/)
          h1_count += 1 if h1_detected

          warn index if h1_count > 1
        end

        warnings
      end

      FAIL = 'each doc must contain exactly one h1'

      def fail
        FAIL
      end
    end
  end
end
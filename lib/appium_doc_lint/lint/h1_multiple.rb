module Appium
  class Lint
    ###
    # Each doc must have exactly 1 h1
    class H1Multiple < Base
      def call
        h1_count = 0
        input.lines.each_with_index do |line, index|
          h1_detected = !! line.match(/^#[^#]/)
          if h1_detected # only warn if h1 detected
            h1_count += 1
            warn index if h1_count > 1
          end
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
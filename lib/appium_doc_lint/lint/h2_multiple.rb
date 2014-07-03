module Appium
  class Lint
    ###
    # Each doc must have exactly 1 h1
    class H2Multiple < Base
      def call
        h1_count = 0
        in_code_block = false
        input.lines.each_with_index do |line, index|
          code_block = !! line.match(/^```/)
          in_code_block = ! in_code_block if code_block

          next if in_code_block

          h1_detected = !! line.match(/^##[^#]/)
          if h1_detected # only warn if h1 detected
            h1_count += 1
            warn index if h1_count > 1
          end
        end

        warnings
      end

      FAIL = 'each doc must contain exactly one h2'

      def fail
        FAIL
      end
    end
  end
end

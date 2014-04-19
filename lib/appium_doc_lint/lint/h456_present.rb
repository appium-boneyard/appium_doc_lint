module Appium
  class Lint
    ###
    # h4, h5, and h6 should not be used.
    # Slate works best with h1, h2, or h3
    class H456Present < Base
      def call
        lines.each_with_index do |line, index|
          h4_h5_h6_present = !! line.match(/^\s*\#{4,6}[^#]/)
          warn index if h4_h5_h6_present
        end

        warnings
      end

      def fail
        'h4, h5, h6 should not be used. Use h1, h2 or h3.'
      end
    end
  end
end
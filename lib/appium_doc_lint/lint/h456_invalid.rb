module Appium
  class Lint
    ###
    # h4, h5, and h6 should not be used.
    # Slate works best with h1, h2, or h3
    class H456Invalid < Base
      def call
        input.lines.each_with_index do |line, index|
          h4_h5_h6_invalid = !!line.match(/^\#{4,6}[^#]/)
          warn index if h4_h5_h6_invalid
        end

        warnings
      end

      FAIL = 'h4, h5, h6 should not be used. Use h1, h2 or h3.'

      def fail
        FAIL
      end
    end
  end
end
=begin
> md.render("##### ok")
=> "<h5>ok</h5>\n"
> md.render(" ##### ok")
=> "<p>##### ok</p>\n"
=end
module Appium
  class Lint
    ###
    # h4, h5, and h6 should not be used.
    # Slate works best with h1, h2, or h3
    class H156Invalid < Base
      def call
        in_code_block = false
        input.lines.each_with_index do |line, index|
          code_block = !! line.match(/^```/)
          in_code_block = ! in_code_block if code_block

          next if in_code_block

          h156_invalid = !!line.match(/^\#{5,6}[^#]|^#[^#]|^===+\s*$/)
          warn index if h156_invalid

        end
        warnings
      end

      FAIL = 'h1, h5, h6 should not be used. Use h2, h3 or h4.'

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

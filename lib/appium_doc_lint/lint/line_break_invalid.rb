module Appium
  class Lint
    ###
    # line breaks such as `--` and `---` shouldn't be used
    # on Slate. They will cause problems such as null divs
    class LineBreakInvalid < Base
      def call
        input.lines.each_with_index do |line, index|
          h4_h5_h6_present = !!line.match(/^--+\s*$/)
          warn index if h4_h5_h6_present
        end

        warnings
      end

      FAIL = '`--` and `---` line breaks must not be used. Delete them.'

      def fail
        FAIL
      end
    end
  end
end

=begin
> md.render(" -- ")
=> "<p>-- </p>\n"
> md.render("-- ")
=> "<h2></h2>\n"
> md.render("--- ")
=> "<hr>\n"
> md.render("--- ok")
=> "<p>--- ok</p>\n
=end
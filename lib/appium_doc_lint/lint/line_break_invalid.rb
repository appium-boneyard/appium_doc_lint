module Appium
  class Lint
    ###
    # line breaks such as `--` and `---` shouldn't be used
    # on Slate. They will cause problems such as null divs
    class LineBreakInvalid < Base
      def call
        previous_line = ''
        input.lines.each_with_index do |line, index|
          # If the previous line isn't empty then --- createa a h2 not a line break.
          previous_line_empty = previous_line.match(/^\s*$/)
          line_break_invalid  = previous_line_empty && line.match(/^--+\s*$/)
          warn index if line_break_invalid

          previous_line = line
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
> md.render "hi\n--"
=> "<h2>hi</h2>\n"
=end
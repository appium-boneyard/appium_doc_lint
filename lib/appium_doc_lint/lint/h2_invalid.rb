module Appium
  class Lint
    ###
    # h2 must use the `##` syntax and not the `---` underline syntax.
    # check for three - to reduce false positives
    class H2Invalid < Base
      def call
        previous_line = ''

        input.lines.each_with_index do |line, index|
          # If the previous line is empty then --- triggers a line break
          previous_line_not_empty = !previous_line.match(/^\s*$/)
          h2_invalid              = previous_line_not_empty && line.match(/^---+\s*$/)
          warn index if h2_invalid

          previous_line = line
        end

        warnings
      end

      FAIL = 'h2 must not use --- underline syntax. Use ## instead'

      def fail
        FAIL
      end
    end
  end
end

=begin
md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
> md.render("hi\n--")
=> "<h2>hi</h2>\n"
> md.render("hi\n -")
=> "<p>hi\n -</p>\n"
> md.render("hi\n- ")
=> "<h2>hi</h2>\n"
=end
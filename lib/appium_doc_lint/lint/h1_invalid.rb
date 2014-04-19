module Appium
  class Lint
    ###
    # h1 must use the `#` syntax and not the `===` underline syntax.
    # check for three = to reduce false positives
    class H1Invalid < Base
      def call
        # === is always a h1 regardless of previous line
        input.lines.each_with_index do |line, index|
          h1_invalid = !!line.match(/^===+\s*$/)
          warn index if h1_invalid
        end

        warnings
      end

      FAIL = 'h1 must not use === underline syntax. Use # instead'

      def fail
        FAIL
      end
    end
  end
end

=begin
md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
> md.render("hi\n=")
=> "<h1>hi</h1>\n"
> md.render("hi\n =")
=> "<p>hi\n =</p>\n"
> md.render("hi\n= ")
=> "<h1>hi</h1>\n"
> md.render("\n\n======")
=> "<h1></h1>\n"
=end
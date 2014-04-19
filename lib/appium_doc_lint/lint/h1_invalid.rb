module Appium
  class Lint
    ###
    # h1 must use the `#` syntax and not the `===` underline syntax.
    # check for three = to reduce false positives
    class H1Invalid < Base
      def call
        input.lines.each_with_index do |line, index|
          invalid_h1 = !!line.match(/^===+\s*$/)
          warn index if invalid_h1
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
=end
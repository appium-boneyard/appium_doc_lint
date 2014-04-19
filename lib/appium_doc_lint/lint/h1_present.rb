module Appium
  class Lint
    ###
    # Each file must have a h1
    # This forms the title for the document and is used to anchor the
    # #filename.md link.
    #
    # The file should start with the h1. This rule will fail if the document
    # doesn't contain at least one h1
    class H1Present < Base
      def call
        h1_missing = ! data.match(/^\s*#[^#]/)
        h1_missing ? warnings << fail : warnings
      end

      def fail
        'h1 not present'
      end
    end
  end
end
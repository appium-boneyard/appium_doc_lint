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
        # either the doc has a h1 or it doesn't
        # attach warning to line 0
        h1_missing = ! data.match(/^#[^#]/m)
        h1_missing ? warn(0) : warnings
      end

      def fail
        'h1 not present'
      end
    end
  end
end
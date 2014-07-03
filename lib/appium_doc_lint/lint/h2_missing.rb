module Appium
  class Lint
    ###
    # Each file must have a h2
    # This forms the title for the document and is used to anchor the
    # #filename.md link.
    #
    # The file should start with the h2. This rule will fail if the document
    # doesn't contain at least one h2
    class H2Missing < Base
      def call
        # either the doc has a h2 or it doesn't
        # attach warning to line 0
        h2_missing = !input.data.match(/^##[^#]/m)
        h2_missing ? warn(0) : warnings
      end

      FAIL = 'h2 is missing'

      def fail
        FAIL
      end
    end
  end
end

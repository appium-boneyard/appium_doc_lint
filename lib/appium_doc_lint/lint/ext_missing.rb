module Appium
  class Lint
    ###
    # all markdown links must have an extension
    #
    # [link to read](readme.md)
    #
    # invalid examples:
    # [link](readme)
    # [link](readme#testing)
    class ExtMissing < Base
      def call
        input.lines.each_with_index do |line, index|
          # regex from github.com/appium/api-docs/lib/api_docs.rb
          # /(?<!!) -- negative look behind. excludes image links
          match_data = line.match(/(?<!!) \[ ( [^\[]* ) \] \( ( [^)\/]+ ) \)/x)
          next unless match_data # skip nil matches
          full        = match_data[0]
          link_text   = match_data[1]
          link_target = match_data[2]

          if link_target && !link_target.include?('/')
            ext = File.extname link_target
            if ext.empty?
              warn index, full
            else
              ext, hash = ext.split '#'
              warn index, full if ext.empty?
            end
          end
        end

        warnings
      end

      FAIL = 'Relative markdown links must have an extension'

      def fail
        FAIL
      end
    end
  end
end
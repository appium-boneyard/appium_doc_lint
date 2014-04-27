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

          match_data = line.match(/(?<!!) \[ ( [^\[]* ) \] \( ( [^)]+ ) \)/x)
          next unless match_data # skip nil matches
          full        = match_data[0]
          link_text   = match_data[1]
          link_target = match_data[2]

          # process docs/en/filename.md#testing links
          link_target = trim_link link_target

          if link_target && !link_target.include?('/')
            ext = File.extname link_target
            if invalid_ext?(ext, link_target)
              warn index, full
            else
              ext, hash = ext.split '#'
              warn index, full if invalid_ext?(ext, link_target)
            end
          end
        end

        warnings
      end

      def invalid_ext? ext, link_target
        ext.empty? && ! link_target.end_with?('/')
      end

      def trim_link link_target
        trim = link_target.start_with?('docs/') && ! link_target.end_with?('/')
        trim ? File.basename(link_target) : link_target
      end

      FAIL = 'Relative markdown links must have an extension'

      def fail
        FAIL
      end
    end
  end
end
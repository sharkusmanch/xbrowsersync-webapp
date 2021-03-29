require 'erb'
require 'json'

module XBookmarkWebClient
  module Output
    class HTMLOutput
      ERB_TEMPLATE = './template.html.erb'
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def output(bookmarks)
        template = ERB.new(File.read(ERB_TEMPLATE))

        File.write(@file, template.result_with_hash(bookmarks: bookmarks))
      end
    end
  end
end

require 'http'
require 'json'
require 'time'

require_relative 'crypto'
require_relative 'log'

module XBookmarkWebClient
  class Updater
    attr_reader :bookmarks, :last_updated

    def initialize(args)
      @opts = default_args.merge(args)
      @bookmarks = {}
      set_timestamp
      @running = true
    end

    def start
      while @running
        begin
          fetch_bookmarks
        rescue StandardError => e
          Log.error("Error fetching bookmarks: #{e}")
        end

        sleep @opts[:interval]
      end
    end

    def stop
      @running = false
    end

    private

    def set_timestamp
      @last_updated = Time.now.to_i
    end

    def fetch_bookmarks
      endpoint = File.join(@opts[:api_host], 'bookmarks', @opts[:user_id])
      Log.debug("API endpoint: #{endpoint}")
      body = HTTP.get(endpoint).body
      Log.debug('Got response from API')

      sync_data = JSON.parse(body)
      @bookmarks = JSON.parse(XBookmarkWebClient::Crypto.decrypt(@opts[:user_id], @opts[:user_password], sync_data))
      set_timestamp

      Log.debug('Successfully updated bookmarks')
    end

    def default_args
      {
        interval: 60,
        user_id: nil,
        user_password: nil,
        api_host: nil
      }
    end
  end
end

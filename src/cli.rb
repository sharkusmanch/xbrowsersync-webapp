require 'clamp'

require_relative 'updater'
require_relative 'output'

Clamp do
  option ["-i", "--interval"], "N", "Seconds to refresh bookmarks from server", environment_variable: 'XBROWSERSYNC_INTERVAL', default: 300 do |s|
    Integer(s)
  end

  option ["-H", "--api-host"], "HOST", "xbrowsersync API host", environment_variable: 'XBROWSERSYNC_API_HOST', default: 'https://api.xbrowsersync.org'

  option ["-u", "--user-id"], "HOST", "xbrowsersync user id", environment_variable: 'XBROWSERSYNC_USER_ID' do |s|
    raise ArgumentError.new('User ID must be 32 characters') unless s.length == 32
    s
  end

  option ["-p", "--user-password"], "HOST", "xbrowsersync user password", environment_variable: 'XBROWSERSYNC_USER_PASSWORD'

  option ["-o", "--output-html-file"], "FILE_PATH", "Path where HTML output file will be written", environment_variable: 'XBROWSERSYNC_OUTPUT_HTML_FILE', default: '/tmp/bookmarks.html'

  def execute
    XBookmarkWebClient::Log.level(:debug)

    updater = XBookmarkWebClient::Updater.new(
      api_host: api_host,
      interval: interval,
      user_id: user_id,
      user_password: user_password
    )

    XBookmarkWebClient::Log.debug('Starting updater thread...')
    updater_thread = Thread.new do
      updater.start
    end
    XBookmarkWebClient::Log.debug('Started updater thread...')

    output = XBookmarkWebClient::Output::HTMLOutput.new(output_html_file)

    last_updated = 0

    while true
      output.output(updater.bookmarks)
      sleep 1 until last_updated < updater.last_updated
      last_updated = updater.last_updated
      XBookmarkWebClient::Log.debug('Updated output')
    end
  end
end
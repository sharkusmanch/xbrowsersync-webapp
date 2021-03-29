require 'mixlib/cli'
require 'erb'

require_relative 'updater'
require_relative 'output'

module XBookmarkWebClient
  class CLI
    include Mixlib::CLI

    option :user_id,
           short: '-u USER_ID',
           long: '--user-id USER_ID',
           required: true,
           description: '32 character user id'

    option :user_password,
           short: '-p USER_PASSWORD',
           long: '--user-password USER_PASSWORD',
           required: true,
           description: 'Password used to encrypt bookmark data'

    option :interval,
           short: '-i SECONDS',
           long: '--interval SECONDS',
           default: 300,
           description: 'Seconds to refresh bookmarks from server',
           proc: proc { |l| l.to_i }

    option :api_host,
           short: '-h API_HOST',
           long: '--api-host API_HOST',
           default: 'https://api.xbrowsersync.org',
           description: 'xbrowsersync host where the bookmark data is stored'

    option :output_html_file,
           short: '-o HTML_FILE_OUT',
           long: '--output-file HTML_FILE_OUT',
           default: '/tmp/bookmarks.html',
           description: 'File where HTML bookmarks page will be written'

    option :help,
           short: '-h',
           long: '--help',
           description: 'Show this message',
           on: :tail,
           boolean: true,
           show_options: true,
           exit: 0
  end
end

XBookmarkWebClient::Log.level(:debug)

cli = XBookmarkWebClient::CLI.new
cli.parse_options

updater = XBookmarkWebClient::Updater.new(
  api_host: cli.config[:api_host],
  interval: cli.config[:interval],
  user_id: cli.config[:user_id],
  user_password: cli.config[:user_password]
)

XBookmarkWebClient::Log.debug('Starting updater thread...')
updater_thread = Thread.new do
  updater.start
end
XBookmarkWebClient::Log.debug('Started updater thread...')

output = XBookmarkWebClient::Output::HTMLOutput.new(cli.config[:output_html_file])

last_updated = 0

while true
  output.output(updater.bookmarks)
  sleep 1 until last_updated < updater.last_updated
  last_updated = updater.last_updated
  XBookmarkWebClient::Log.debug('Updated output')
end

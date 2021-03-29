#! /bin/ash

nginx
bundle exec ruby cli.rb --user-id $XBROWSERSYNC_USER_ID  -p "$XBROWSERSYNC_USER_PASSWORD" -o /www/data/bookmarks.html
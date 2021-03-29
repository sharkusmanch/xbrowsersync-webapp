# xBrowserSync Web App

## Overview

A simple web application to retrieve a single user's bookmarks from a xBrowserSync backend and provide them as simple web page.

## Usage

```bash
docker run -it --rm -p 80:8080 -e XBROWSERSYNC_USER_ID="$XBROWSERSYNC_USER_ID" -e XBROWSERSYNC_USER_PASSWORD="$XBROWSERSYNC_USER_PASSWORD"  sharkusmanch/xbrowsersync-webapp
```
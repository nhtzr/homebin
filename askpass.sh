#!/usr/bin/env sh
osascript -e "
  on GetCurrentApp()
      tell application \"System Events\"
          set _app to item 1 of (every process whose frontmost is true)
          return name of _app
      end tell
  end GetCurrentApp
  set _app to GetCurrentApp()
  tell application _app
      text returned of (display dialog \"Please enter your password:\" ¬
        with title \"Password\" ¬
        with icon caution ¬
        default answer \"\" ¬
        buttons {\"Cancel\", \"OK\"} default button 2 ¬
        giving up after 295 ¬
        with hidden answer)
  end tell
  "

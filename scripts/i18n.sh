#!/usr/bin/env bash

main()
{  
  if [ -z $(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep '"Bundle ID" = "com.apple.inputmethod.') ]; then
    tmux set-option -ga status-right "#[fg=${green},bg=${gray}] A"
  else
    tmux set-option -ga status-right "#[fg=${gray},bg=${green}] 한"
  fi
}

main 

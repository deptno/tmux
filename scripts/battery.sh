#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

linux_acpi() {
  arg=$1
  BAT=$(ls -d /sys/class/power_supply/BAT* | head -1)
  if [ ! -x "$(which acpi 2> /dev/null)" ];then
    case "$arg" in
      status)
        cat $BAT/status
        ;;

      percent)
        cat $BAT/capacity
        ;;

      *)
        ;;
    esac
  else
    case "$arg" in
      status)
        acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' '
        ;;
      percent)
        acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% '
        ;;
      *)
        ;;
    esac
  fi
}

battery_percent()
{
  # Check OS
  case $(uname -s) in
    Linux)
      percent=$(linux_acpi percent)
      [ -n "$percent" ] && echo " $percent"
      ;;

    Darwin)
      printf "%03d%%" $(pmset -g batt | grep -Eo '[0-9]?[0-9]?[0-9]%' | cut -d '%' -f1)
      ;;

    FreeBSD)
      echo $(apm | sed '8,11d' | grep life | awk '{print $4}')
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # leaving empty - TODO - windows compatability
      ;;

    *)
      ;;
  esac
}

battery_status()
{
  # Check OS
  case $(uname -s) in
    Linux)
      status=$(linux_acpi status)
      ;;

    Darwin)
      status=$(pmset -g batt | sed -n 2p | cut -d ';' -f 1-| tr -d " ")
      ;;

    FreeBSD)
      status=$(apm | sed '8,11d' | grep Status | awk '{printf $3}')
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # leaving empty - TODO - windows compatability
      ;;

    *)
      ;;
  esac

  case $(uname -s) in
    Darwin)
      case $status in
        *discharging*)
          printf "ﮤ " 
          echo $status | cut -d ';' -f 3| grep -Eo "\d{1,2}:\d{1,2}"
          ;;
        *"not charging"*)
          echo ''
          ;;
        *charging*)
          case $1 in
            100%|09*%)
              echo ''
              ;;
            08*%|07*%)
              echo ''
              ;;
            06*%|05*%|04*%)
              echo 
              ;;
            03*%|02*%|010%)
              echo ''
              ;;
            00*%)
              echo ''
              ;;
            *)
              echo ''
              ;;
          esac
          ;;
        *)
          echo ''
          ;;
      esac
      ;;
    *)
    case $status in
      discharging|Discharging)
        echo ''
        ;;
      high)
        echo ''
        ;;
      charging)
        echo 'AC'
        ;;
      *)
        echo 'AC'
        ;;
    esac
    ;;
  esac
  ### Old if statements didn't work on BSD, they're probably not POSIX compliant, not sure
  # if [ $status = 'discharging' ] || [ $status = 'Discharging' ]; then
  # 	echo ''
  # # elif [ $status = 'charging' ]; then # This is needed for FreeBSD AC checking support
  # 	# echo 'AC'
  # else
  #  	echo 'AC'
  # fi
}

main()
{
  bat_label=$(get_tmux_option "@dracula-battery-label" "♥")
  bat_perc=$(battery_percent)
  bat_stat=$(battery_status $bat_perc)

  if [ -z "$bat_stat" ]; then # Test if status is empty or not
    echo "$bat_label$bat_perc"
  elif [ -z "$bat_perc" ]; then # In case it is a desktop with no battery percent, only AC power
    echo "$bat_label$bat_stat"
  else
    echo "$bat_label$bat_stat $bat_perc"
  fi
}

#run main driver program
main


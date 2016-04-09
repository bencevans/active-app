#!/bin/sh

# #
# # log-active-x11-window.sh thanks to https://gist.github.com/andrewharvey/3993142
# #

# = About =
# This script when run will log details of the current active X11 window.
# Useful for logging/graphing how much time is spent in different apps.

# = Usage =
# If --datetime is present as the first argument, the log line will include the
# date and time.
#
# It is up to you to decide how and when you want to run the script. If you
# want to continually log using a poll interval you may want to use,
#
#     while `sleep 1s`; do ./log-active-x11-window.sh --datetime ; done > /var/log/log-active-x11-window.log
#
# Perhaps combining this with a logrotate configuration for the log file to
# keep the files and file size manageable.

# = License =
# License: CC0 http://creativecommons.org/publicdomain/zero/1.0/
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# = Dependencies =
# This script requires wmctrl, x11-utils.

# = Output Format =
# The output will be a tab separated single line of format:
#    datetime stamp (if --datetime argument was used)
#    desktop_number
#    process_id
#    x_offset
#    y_offset
#    width
#    height
#    machine_name
#    ps_name
#    cmdline (NUL separated)
#    window_title (could contain spaces)

# = Design Principle =
# Although you could include many other things within this script such as
# infinitely looping with a sleep, logging to alternate formats, doing so
# would violate the UNIX principle of simple single unit programs.
# I believe it is best to keep this script minimal and adding other
# functionality over the top with other scripts which call this one.
#
# That said, if you are executing this with high frequency, for performance
# reasons you may need to build the functionality into this script.

# = Acknowledgements =
# Many thanks to http://superuser.com/users/15947/dave-vogt and
# http://superuser.com/users/115616/tao for [providing hints on the
# commands available to extract the required information]
# (http://superuser.com/q/382616).


### First get the window id of the active window

#    list X11 properties
#    get the ACTIVE_WINDOW property
#    get the window id
#    we need a fixed width of 16 bytes to compare to wmctrl
active_window_id=$(xprop -root | \
  grep _NET_ACTIVE_WINDOW | grep 'window id' | \
  cut -d' ' -f5 | \
  sed 's/^0x/0x0/')

# get the wmctrl details of the active window
# -l list all windows managed by the window manager
# -p print the process id for the window
# -G print the geometry details of the window
wmctrl_active_window=$(wmctrl -lpG | grep "^$active_window_id")
wmctrl_exit_status=$?

if [ "$wmctrl_exit_status" -eq 0 ] ; then
    # parse out the response from wmctrl
    desktop_number=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f2)
    process_id=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f3)
    x_offset=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f4)
    y_offset=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f5)
    width=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f6)
    height=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f7)
    machine_name=$(echo $wmctrl_active_window | sed "s/\s+/ /g" | cut -d' ' -f8)

    window_title=$(echo $wmctrl_active_window | sed --regexp-extended "s/^$active_window_id[ ]+([^ ]+)[ ]+([0-9]+)[ ]+(-?[0-9]+)[ ]+(-?[0-9]+)[ ]+([0-9]+)[ ]+([0-9]+)[ ]+([^ ]+)[ ]+(.*)$/\8/")

    # get the process name of the process running the active window
    ps_name=$(cat /proc/$process_id/status | grep 'Name:' | cut -f2) # TAB separated

    # get the process command line of the process running the active window then cut just argument zero
    cmdline=$(cat /proc/$process_id/cmdline) # NUL separated
    arg0=$(cat /proc/$process_id/cmdline | cut -d '' -f1) # cut -d '' will cut on NUL

    # include the date in the log if asked for
    if [ "--datetime" = "$1" ] ; then
        date=$(date --utc --rfc-3339=seconds)
    fi

    # log details to STDOUT
    echo "$date$desktop_number\t$process_id\t$x_offset\t$y_offset\t$width\t$height\t$machine_name\t$ps_name\t$cmdline\t$window_title"
fi

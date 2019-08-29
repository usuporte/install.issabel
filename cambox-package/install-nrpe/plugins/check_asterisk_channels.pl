#!/bin/sh

# Check asterisk channels/calls plugin for Nagios.
# Written by Chad Phillips (chad@apartmentlines.com)
# Last Modified: 2009-02-28

ASTERISK=/usr/sbin/asterisk

PROGPATH=`dirname $0`
REVISION=`echo '$Revision: 1 $' | sed -e 's/[^0-9.]//g'`
DATETIME=`date "+%Y-%m-%d %H:%M:%S"`
TAB="	"

. $PROGPATH/utils.sh

print_usage() {
    echo "
Usage: check_asterisk_channels [-w <max_channels>] [-c <max_channels>] [-W <max_calls>] [-C <max_calls>]
Usage: check_asterisk_channels --help | -h

Description:

This plugin checks an asterisk server for active channels and calls, and issues
alerts if any defined thresholds are exceeded.  Performance data is also
returned for both active channels and calls.

Tested to work on Linux.

The following arguments are accepted:

  -w              (Optional) Generate a warning message if the defined number
                  channels is exceeded.

  -c              (Optional) Generate a critical message if the defined number
                  channels is exceeded.

  -W              (Optional) Generate a warning message if the defined number
                  calls is exceeded.

  -C              (Optional) Generate a critical message if the defined number
                  calls is exceeded.

  --help | -h     Print this help and exit.

Examples:

Check channels/calls, with no concern about limits.

  check_asterisk_channels

Check channels/calls.  Issue a warning if there are more than 10 active
channels, and a critical if there are more than 15 active channels.

  check_asterisk_channels -w 10 -c 15

Caveats:

This plugin calls the asterisk executable directly, so make sure that the user
executing this script has appropriate permissions!  Usually the asterisk binary
can only be run by the asterisk user or root. To grant the nagios user
permissions to execute the script, try something like the following in your
/etc/sudoers file:
  nagios ALL=(ALL) NOPASSWD: /path/to/plugins/directory/check_asterisk_channels

Then call the plugin using sudo:
  /path/to/sudo check_asterisk_channels
"
}

print_help() {
    print_usage
    echo "Check asterisk channels/calls plugin for Nagios."
    echo ""
}

# Sets the exit status for the plugin.  This is done in such a way that the
# status can only go in one direction: OK -> WARNING -> CRITICAL.
set_exit_status() {
	new_status=$1
	# Nothing needs to be done if the state is already critical, so exclude
	# that case.
	case $exitstatus
	in
		$STATE_WARNING)
			# Only upgrade from warning to critical.
			if [ "$new_status" = "$STATE_CRITICAL" ]; then
				exitstatus=$new_status;
			fi
		;;
		$STATE_OK)
			# Always update state if current state is OK.
			exitstatus=$new_status;
		;;
	esac
}

# Ensures that a call to the Asterisk process returns successfully.  Exits
# critical if not.
check_asterisk_result() {
	if [ "$1" != "0" ]; then
		echo "CRITICAL: $2"
		exit $STATE_CRITICAL
	fi
}

# Defaults.
exitstatus=$STATE_OK
channels_warning=-1
channels_critical=-1
calls_warning=-1
calls_critical=-1

# Grab the command line arguments.
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        -w)
            channels_warning=$2
            shift
            ;;
        -c)
            channels_critical=$2
            shift
            ;;
		-W)
			calls_warning=$2
			shift
            ;;
		-C)
			calls_critical=$2
			shift
            ;;
        -x)
            exitstatus=$2
            shift
            ;;
        --exitstatus)
            exitstatus=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

# Sanity checking for arguments.
if [ "$channels_warning" != "-1" ] && ([ ! "$channels_warning" ] || [ `echo "$channels_warning" | grep [^0-9]` ]); then
	echo "Number of channels warning value must be a number."
	exit $STATE_UNKNOWN
fi

if [ "$channels_critical" != "-1" ] && ([ ! "$channels_critical" ] || [ `echo "$channels_critical" | grep [^0-9]` ]); then
	echo "Number of channels critical value must be a number."
	exit $STATE_UNKNOWN
fi

if [ "$channels_warning" != "-1" ] && [ "$channels_critical" != "-1" ] && [ "$channels_warning" -ge "$channels_critical" ]; then
	echo "Critical channels must be greater than warning channels."
	exit $STATE_UNKNOWN
fi

if [ "$calls_warning" != "-1" ] && ([ ! "$calls_warning" ] || [ `echo "$calls_warning" | grep [^0-9]` ]); then
	echo "Number of calls warning value must be a number."
	exit $STATE_UNKNOWN
fi

if [ "$calls_critical" != "-1" ] && ([ ! "$calls_critical" ] || [ `echo "$calls_critical" | grep [^0-9]` ]); then
	echo "Number of calls critical value must be a number."
	exit $STATE_UNKNOWN
fi

if [ "$calls_warning" != "-1" ] && [ "$calls_critical" != "-1" ] && [ "$calls_warning" -ge "$calls_critical" ]; then
	echo "Critical calls must be greater than warning calls."
	exit $STATE_UNKNOWN
fi

# Fetch the data from asterisk.
command_output=`$ASTERISK -rx "core show channels" 2>&1`
check_asterisk_result $? "$command_output"

# Parse the data.
call_data=`echo "$command_output" | tail -n 2`
active_channels=`echo "$call_data" | head -n 1 | cut -f 1 -d " "`
active_calls=`echo "$call_data" | tail -n 1 | cut -f 1 -d " "`

# Test for warning/critical channels.
if [ "$channels_critical" != "-1" ] && [ "$active_channels" -gt "$channels_critical" ]; then
	set_exit_status $STATE_CRITICAL
elif [ "$channels_warning" != "-1" ] && [ "$active_channels" -gt "$channels_warning" ]; then
	set_exit_status $STATE_WARNING
fi

# Test for warning/critical calls.
if [ "$calls_critical" != "-1" ] && [ "$active_calls" -gt "$calls_critical" ]; then
	set_exit_status $STATE_CRITICAL
elif [ "$calls_warning" != "-1" ] && [ "$active_calls" -gt "$calls_warning" ]; then
	set_exit_status $STATE_WARNING
fi


case $exitstatus
in
	$STATE_CRITICAL)
		exit_message="CRITICAL";
	;;
	$STATE_WARNING)
		exit_message="WARNING";
	;;
	$STATE_OK)
		exit_message="OK";
	;;
	*)
		echo "UNKNOWN"
		exit $STATE_UNKNOWN;
		
	;;
esac

echo "${exit_message}: $active_channels active channels, $active_calls active calls | ${DATETIME}${TAB}${active_channels}${TAB}${active_calls}";

exit $exitstatus


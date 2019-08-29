#!/bin/sh

# Check asterisk peers plugin for Nagios.
# Written by Chad Phillips (chad@apartmentlines.com)
# Last Modified: 2009-05-02

ASTERISK=/usr/sbin/asterisk

PROGPATH=`dirname $0`
REVISION=`echo '$Revision: 2 $' | sed -e 's/[^0-9.]//g'`

. $PROGPATH/utils.sh

print_usage() {
    echo "
Usage: check_asterisk_peers [--type | -t <sip|iax>] [--peers | -p <peers>] [--registrations | -r <registrations>] [--verify-peers] [--verify-registrations] [--config-file <filepaths>]
Usage: check_asterisk_peers --help | -h

Description:

This plugin checks Asterisk peers via Asterisk CLI commands to make sure
they are in a healthy state.  Unlike other monitoring plugins, status
is obtained from the perspective of the Asterisk server -- it's a good plugin
to use for monitoring the state of your connections to providers.

Both the peer itself and registration status to a peer can be monitored,
with the option of verifying that the peer/registration is actively configured.

If any of the checked peers/registrations return a non-OK state, a critical
state is returned. If verification is being used and a peer/registration is
not verified as being in the active configuration, then the status check is
skipped for that item instead of a critical state being returned.

Tested to work on Linux.

The following arguments are accepted:

  --type  | -t            (Optional) The type of peer to check.  Valid values
                          are sip, iax. Defaults to sip.

  --peers | -p            (Optional) A space separated list of peers to check.
                          Use the peer name given in the configuration,
                          without the surrounding brackets.

  --registrations | -r    (Optional) A space separated list of registrations
                          to check, in the form of username@uri. For example,
                          to check the registration of peer foo to
                          somesite.com, use foo@somesite.com

  --verify-peers          (Optional) If set, peer entries are verified in
                          the configuration, and the check is skipped
                          if they are not found.

  --verify-registrations  (Optional) If set, registrations are verified in
                          the configuration, and the check is skipped
                          if they are not found.

  --config-file           (Optional) The location of the configuration file(s).
                          Use a space separated list if specifying multiple
                          files.

                          Default value is based on the --type setting:

                          sip: /etc/asterisk/sip.conf
                          iax: /etc/asterisk/iax.conf

  --help | -h             Print this help and exit.

Examples:

Check peers [foo] and [bar]:

  check_asterisk_peers -p \"foo bar\"

Check peers [foo] and [bar], and registration for usr baz at somesite.com,
and verify that both the peers and the registration are actively configured.

  check_asterisk_peers -p \"foo bar\" -r \"baz@somesite.com\" --verify-peers --verify-registrations

Caveats:

The verification checks will not work correctly if there is any leading or
trailing whitespace on any of the register statement lines or the peer
section headings.

This plugin does not work with Realtime.

This plugin calls the asterisk executable directly, so make sure that the user
executing this script has appropriate permissions!  Usually the asterisk binary
can only be run by the asterisk user or root. To grant the nagios user
permissions to execute the script, try something like the following in your
/etc/sudoers file:
  nagios ALL=(ALL) NOPASSWD: /path/to/plugins/directory/check_asterisk_peers

Then call the plugin using sudo:
  /path/to/sudo check_asterisk_peers
"
}

print_help() {
    print_usage
    echo "Check asterisk peers plugin for Nagios."
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

# Recurse through the configuration file and find all included files, building
# a final list of files to use for verification checks.
get_config_files() {
	for file in $1
	do
		if [ "$conf_file_list" ]; then
			conf_file_list="$conf_file_list $file"
		else
			conf_file_list="$file"
		fi
		files=`cat $file | grep ^\#include | awk '{print $2;}'`
		if [ "$files" ]; then
			get_config_files "$files"
		fi
	done
}

# Defaults.
exitstatus=$STATE_OK
peers=
registrations=
verify_peers=
verify_registrations=
peer_type=
conf_file=
conf_file_list=
all_config=
test_ok=
test_errors=
output=

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
        --peers)
            peers=$2
            shift
            ;;
        -p)
            peers=$2
            shift
            ;;
		--registrations)
			registrations=$2
			shift
            ;;
		-r)
			registrations=$2
			shift
            ;;
        --verify-peers)
        	verify_peers=1
        	;;
        --verify-registrations)
        	verify_registrations=1
        	;;
        --type)
            peer_type=$2
            shift
            ;;
        -t)
            peer_type=$2
            shift
            ;;
        --conf-file)
        	conf_file=$2
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

# Make sure we have a valid peer type.
if [ "$peer_type" != "" ] && [ "$peer_type" != "sip" ] && [ "$peer_type" != "iax" ]; then
	echo "Peer type must be one of: sip, iax."
	exit $STATE_UNKNOWN
# Convert iax type into internal iax2 type for the Asterisk executable.
elif [ "$peer_type" = "iax" ]; then
	peer_type=iax2
# Default type is SIP.
else
	peer_type=sip
fi

if [ ! "$peers" ] && [ ! "$registrations" ]; then
	echo "At least one peer or registration must be provided."
	exit $STATE_UNKNOWN
fi

# Set a default configuration file if none was set.
if [ "$conf_file" = "" ]; then
	if [ "$peer_type" = "iax2" ]; then
		conf_file=/etc/asterisk/iax.conf
	else
		conf_file=/etc/asterisk/sip.conf
	fi
fi

# Check to make sure the registrations are in the username@uri format.
# This is a weak check, but at least enough to make sure we have something
# in the user/uri variables.
if [ "$registrations" ]; then
	for r in $registrations
	do
		REGISTRATION_FORMAT_CORRECT=`echo "$r" | grep ".\+@.\+"`
		if [ ! "$REGISTRATION_FORMAT_CORRECT" ]; then
			echo "Registration $r is not in the valid username@uri format."
			exit $STATE_UNKNOWN
		fi
	done
fi

# Load the configuration files if necessary.
if [ "$verify_peers" ] || [ "$verify_registrations" ]; then
	get_config_files $conf_file
	all_config=`cat $conf_file_list`
fi

# Check peers.
if [ "$peers" ]; then
	for p in $peers
	do
		if [ "$verify_peers" ]; then
			peer_verified=`echo "$all_config" | grep "^\[${p}\]$"`
		else
			peer_verified=1
		fi
		if [ "$peer_verified" ]; then
			# Fetch the data from asterisk.
			command_output=`$ASTERISK -rx "$peer_type show peer $p" 2>&1`
			check_asterisk_result $? "$command_output"
			status=`echo "$command_output" | grep "^[[:space:]]*Status[[:space:]]*:" | awk '{print $3;}'`
			if [ "$status" = "OK" ]; then
				if [ "$test_ok" ]; then
					test_ok="${test_ok}, $p"
				else
					test_ok="$p"
				fi
			else
				if [ "$status" ]; then
					status_error="$status"
				else
					status_error="Not found"
				fi
				if [ "$test_errors" ]; then
					test_errors="${test_errors}, ${p}: $status_error"
				else
					test_errors="${p}: $status_error"
				fi
			fi
		else
			if [ "$test_ok" ]; then
				test_ok="${test_ok}, $p (not active)"
			else
				test_ok="$p (not active)"
			fi
		fi
	done
fi

# Check registrations.
if [ "$registrations" ]; then
	# Fetch the data from asterisk.
	command_output=`$ASTERISK -rx "$peer_type show registry" 2>&1`
	check_asterisk_result $? "$command_output"
	for r in $registrations
	do
		user=`echo $r | cut -f 1 -d "@"`
		# Add backslashes to escape the dot.
		uri=`echo $r | cut -f 2 -d "@" | sed -e 's/\./\\\./g'`
		if [ "$verify_registrations" ]; then
			# This regex isn't perfect, but it does the trick ok.
			registration_verified=`echo "$all_config" | grep "^register => ${user}:.\+@${uri}$"`
		else
			registration_verified=1
		fi
		if [ "$registration_verified" ]; then
			# Have to cut off registration name at 12 characters, so let's hope
			# it's still unique!
			cut_user=${user:0:12}
			# This regex isn't perfect, but it does the trick ok.
			status=`echo "$command_output" | grep "^${uri}:[[:digit:]].\+[[:space:]].\+${cut_user}[[:space:]].\+" | awk '{print $4;}'`
			if [ "$status" = "Registered" ]; then
				if [ "$test_ok" ]; then
					test_ok="${test_ok}, $r"
				else
					test_ok="$r"
				fi
			else
				if [ "$status" ]; then
					status_error="$status"
				else
					status_error="Not found"
				fi
				if [ "$test_errors" ]; then
					test_errors="${test_errors}, ${r}: $status_error"
				else
					test_errors="${r}: $status_error"
				fi
			fi
		else
			if [ "$test_ok" ]; then
				test_ok="${test_ok}, $r (not active)"
			else
				test_ok="$r (not active)"
			fi
		fi
	done
fi

if [ "$test_errors" ]; then
	output="$output ERROR: $test_errors"
	set_exit_status $STATE_CRITICAL
fi

if [ "$test_ok" ]; then
	output="$output OK: $test_ok"
fi

if [ ! "$output" ]; then
	echo "UNKNOWN: No output"
	exit $STATE_UNKNOWN
fi

echo "$output"
exit $exitstatus
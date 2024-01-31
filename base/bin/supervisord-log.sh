#!/bin/sh

# When used as a wrapper within a supervisord program configuration block,
# all STDOUT and STDERR log lines will be prefixed with a timestamp + the
# program name.
#
# The log line format matches supervisords log line format.
# This requires perl to be installed.
#
# From https://github.com/Supervisor/supervisor/issues/553#issuecomment-1584926718
#
#
# Example usage in a supervisord '[program:x]' block
#[program:process-1]
#command=/bin/supervisord-log.sh executable1

# Prefix outputs with Time Stamp and Process Name
exec 1> >( perl -ne 'use Time::HiRes qw(time); use POSIX qw( strftime ); $time=time; $microsecs = ($time - int($time)) * 1e3; $| = 1; printf( "%s,%03.0f '"${SUPERVISOR_PROCESS_NAME}"'%s", strftime("%Y-%m-%d %H:%M:%S", gmtime($time)), $microsecs, $_);' >&1)
exec 2> >( perl -ne 'use Time::HiRes qw(time); use POSIX qw( strftime ); $time=time; $microsecs = ($time - int($time)) * 1e3; $| = 1; printf( "%s,%03.0f '"${SUPERVISOR_PROCESS_NAME}"'%s", strftime("%Y-%m-%d %H:%M:%S", gmtime($time)), $microsecs, $_);' >&2)

exec "$@"

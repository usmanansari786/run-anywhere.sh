#!/bin/bash
#
SERVER_LIST='/vagrant/servers'
SERVER=$(cat "${SERVER_LIST}")
SSH_OPTIONS='-o ConnectionTimeout=2'

# Display the usage and exit
usage() {
  echo 'Usage: ./run-everywhere.sh [-nsv] [-f FILE] COMMAND' >&2
  echo 'Executes COMMAND as a single command on every server.' >&2
  echo
  echo '  -f FILE Use FILE for the list of servers. Default: /vagrant/servers.' >&2
  echo
  echo '  -n Dry run mode. Display the COMMAND that would have been executed and exit.' >&2
  echo
  echo '  -s Execute the COMMAND using sudo on the remote server.'>&2
  echo
  echo '  -v Verbose mode. Displays the server name before executing COMMAND' >&2
  exit 1
}

# Make sure the script is not being executed with superuser privileges
if [[ ${UID} -ne 1000 ]]
then
  echo "Do not execute this script as root. Use the -s option instead" >&2
  exit 1
  usage
fi

# Parse the optons
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f)
     FILE='true'
     SERVER_LIST="${OPTARG}"
    ;;
    n)
     DRY='true'
    ;;
    s)
     SUDO='sudo'
     echo "Using superuser privileges" >&2
    ;;
    v)
     VERBOSE='true'
    ;;
    ?)
     usage
    ;;
  esac
done

# Remove the options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# If the user dosent supply at least one argument, give them help
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Anything that remains on the command line is to be treated as a single command
COMMAND="${@}"

if [[ ${FILE} == 'true' ]]
then
  OPTARG="${COMMAND}"
fi

# Make sure the SERVER_LIST file exists
if [[ ! -e ${SERVER_LIST} ]]
then
  echo "The file ${SERVER_LIST} does not exist" >&2
  exit 1
fi

# Loop through the SERVER_LIST
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ ${VERBOSE} -eq 'true' ]]
    then
    echo "${SERVER}"
  fi

SSH_COMMAND="ssh ${SERVER} ${SUDO} ${COMMAND}"

# If its a dry run, dont execute anything, just echo it
if [[ "${DRY}" == 'true' ]]
then
  echo "DRY RUN: ${SSH_COMMAND}"
  exit 0
fi

${SSH_COMMAND}
SSH_EXIT_STATUS="${?}"

# Capture any non-zero status from the SSH_COMMAND and report to the user
if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
then
  EXIT_STATUS="${SSH_EXIT_STATUS}"
  echo "Execution on ${SERVER} failed" >&2
fi
done

exit ${EXIT_STATUS}

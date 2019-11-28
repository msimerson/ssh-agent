#!/bin/sh

# ssh-agent
#
# autoloads the ssh-agent and keys into each terminal session, so we
# can use ssh-agent without thinking about it.
#
# https://github.com/msimerson/ssh-agent/
#
# VERSION: 1.05
#    https://github.com/msimerson/ssh-agent/blob/master/Changes.md
#
# GUI APPLICATIONS
#
#   If you use GUI apps that are ssh-agent aware, you will need to run the
#   script once, log out, and log back in. Then your GUI apps will be
#   ssh-agent aware.

unset _sockfile
_agent_opts=""   # set any desired ssh-agent options here

# use env $TMPDIR if defined, otherwise default to /tmp
TMPDIR=${1-/tmp}

# See README file, SSH-AGENT SOCKET note
_sockfile="${HOME}/.ssh/agent.sock"

is_login_shell_bash()
{
    if expr "$SHELL" : '.*bash' >> /dev/null; then
        # echo "yes"
        return 0
    else
        # echo "no"
        return 1
    fi
}

if is_login_shell_bash && [ "$0" != "-bash" ];
then
    echo '
OOPS! Did you mean to source this script? Try this:

    source ~/.ssh/agent.sh
'
fi

if [ -n "$_sockfile" ];
then
    _agent_opts="-s -a $_sockfile $_agent_opts"
fi

main()
{
    discover_ssh_agent

    # 1. ssh-agent not running.
    if [ -z "${_agent_pid}" ];
    then
        cleanup_stale_agent
        start_ssh_agent
        return
    fi

    # 2. ssh-agent is running but...
    #
    # SSH_AGENT_PID is set but different than running ssh-agent pid
    if [ -n "$SSH_AGENT_PID" ] && [ "$SSH_AGENT_PID" -ne "${_agent_pid}" ];
    then
        cleanup_stale_agent
        discover_ssh_agent
        return
    fi

    ssh-add -l > /dev/null   # try to contact ssh-agent
    if [ $? -eq 2 ];         # communication failed
    then
        echo "ssh-agent socket is stale"
        kill "${_agent_pid}"   # kill ssh-agent
        killall pgrep ssh-agent -U "$USER"
        cleanup_stale_agent
        start_ssh_agent
        return
    fi
}

set_agent_pid()
{
    # echo "checking for ssh-agent process"
    _agent_pid=$(pgrep -U "$USER" ssh-agent | tail -n1)
}

set_socket_file()
{
    # if _sockfile is not defined we must figure it out
    if [ -z "$_sockfile" ] || [ ! -e "$_sockfile" ];
    then
        _sock_pid=$(echo "${_agent_pid}" - 1 | bc)
        _sockfile=$(/bin/ls "$TMPDIR/ssh-*/agent.${_sock_pid}")
    fi

    if [ ! -e "$_sockfile" ];
    then
        echo "ERROR: could not determine ssh-agent socket file for pid: $SSH_AGENT_PID"
        return
    fi

    export SSH_AUTH_SOCK=$_sockfile
}

discover_ssh_agent()
{
    set_agent_pid

    if [ -z "$_agent_pid" ];   # no agent PID discovered
    then
        echo "ssh agent is not running"
        return
    fi

    echo "ssh agent for $USER found at pid ${_agent_pid}."
    export SSH_AGENT_PID="${_agent_pid}"

    set_socket_file

    # make sure the Mac Login environment is configured
    if [ "$(uname)" = "Darwin" ]; then
        setup_plist
    fi
}

start_ssh_agent()
{
    echo "starting ssh-agent $_agent_opts"
    # shellcheck disable=SC2046,SC2086
    eval $(ssh-agent $_agent_opts) || return

    discover_ssh_agent

    if [ -n "$SSH_AUTH_SOCK" ];
    then
        echo "adding ssh key(s) to agent"
        if [ "$(uname)" = "Darwin" ]; then
            # loads SSH keys stored in OS X Keychain
            ssh-add -A
        fi
        # this will prompt the user to authenticate their password protected ssh key(s)
        ssh-add
    fi
}

setup_plist()
{
    _envdir="$HOME/.MacOSX"

    if [ ! -d "$_envdir" ]; then
        mkdir "$_envdir"
    fi

    _plist="$_envdir/environment.plist"

    if [ -e "$_plist" ];
    then
        grep -q "$_sockfile" "$_plist"
        ENVSET=$?
        if [ ! $ENVSET ]; then
            set +o noclobber
            write_plist    # check and update
        fi
    else
        write_plist        # create
    fi
}

write_plist()
{
    echo "updating Mac OS X environment"
    (
    cat <<EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
 <dict>
  <key>SSH_AUTH_SOCK</key>
  <string>${_sockfile}</string>
 </dict>
</plist>
EOXML
    ) > "$_plist"
}

cleanup_stale_agent()
{
    # check the environment variable SSH_AGENT_PID as it could be set
    # despite the ssh-agent process being missing.
    if [ -n "$SSH_AGENT_PID" ];
    then
        echo "cleaning stale SSH_AGENT_PID: $SSH_AGENT_PID"
        unset SSH_AGENT_PID
    fi

    if [ -n "$SSH_AUTH_SOCK" ];
    then
        echo "cleaning stale SSH_AUTH_SOCK"
        unset SSH_AUTH_SOCK
    fi

    if [ -e "$_sockfile" ];
    then
        echo "removing stale socket file: $_sockfile"
        unlink "$_sockfile"
    fi
}

print_agent_info() {
    echo "pid :  $_agent_pid"
    echo "sock:  $_sockfile"
}


main
#print_agent_info

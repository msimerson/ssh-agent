# ssh-agent

A bash script that autoloads the ssh-agent and keys into each terminal session
of a workstation, significantly reducing the complexity of using ssh-agent.

Used and tested on Mac OS X, FreeBSD, and Linux computers. Should work on any
UNIXy host with OpenSSH installed.

# INSTALL

1. Install to $HOME/.ssh directory as agent.sh

        curl -L -o .ssh/agent.sh https://github.com/msimerson/ssh-agent/raw/master/agent.sh
        chmod 755 .ssh/agent.sh

2. Run it when new terminal windows open

        echo 'source .ssh/agent.sh' >> ~/.bash\_profile

3. Open new terminal/shell sessions

4. Enjoy


## SSH-AGENT SOCKET

Setting \_sockfile is an efficiency improvement. Rather than storing the
ssh socket file in /tmp/ssh-XXXXXXXXXX/agent.<ppid> and having to glob
to find it, we can store it in a fixed location so this script can find
it more efficiently. Since all our shell/terminal windows will share the
first ssh-agent process, there is no need for the random location.

If you decide to alter the location, keep security in mind. You do not want
others to have access to this socket. Your ~/.ssh directory is a great
choice because its default permissions (600) are readable only by you.

If you wish to keep the default /tmp behavior, comment out the \_sockfile setting.

## end

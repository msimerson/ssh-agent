ssh-agent
=========

A bash script that autoloads the ssh-agent and keys into each terminal session
of a workstation, significantly reducing the complexity of using ssh-agent.


INSTALL
=========

1. Install to $HOME/.ssh directory as agent.sh

   curl -o .ssh/agent.sh http://www.tnpi.net/computing/mac/agent.sh.txt
   chmod 755 .ssh/agent.sh

2. Run it when new terminal windows open

   echo 'source .ssh/agent.sh' >> ~/.bash_profile

3. Open new terminal/shell sessions

4. Enjoy


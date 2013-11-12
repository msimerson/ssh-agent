ssh-agent
=========

A bash script that autoloads the ssh-agent and keys into each terminal session
of a workstation, significantly reducing the complexity of using ssh-agent.


INSTALL
=========

#. Install this script in your ~/.ssh directory as agent.sh

   curl -o .ssh/agent.sh http://www.tnpi.net/computing/mac/agent.sh.txt
   chmod 755 .ssh/agent.sh

#. Configure it to run when a new terminal window opens

   echo 'source .ssh/agent.sh' >> ~/.bash_profile

#. Open new terminal/shell sessions

#. Enjoy

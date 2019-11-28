
# VERSION - CHANGES

### 1.06 - Nov 27, 2019

* SC2086, quote strings
* Update README with zsh instructions

### 1.05 - Nov 12, 2013

* use TMPDIR if defined, default to /tmp (was hard coded /tmp)

### 1.04 - Mar 25, 2011 (abe ingersoll)

* bash didn't like `grep`, call normally and check $? instead

### 1.03 - May 24, 2010

* test agent socket file, restart ssh-agent if socket is stale
* moved set_socket_file into its own sub

### 1.02 - Dec 16, 2007

* adjusted ps invocation for reliable detection when multiple users run ssh-agent on a single system

### 1.01 - Oct 9, 2007

* when cleaning up stale agent, remove stale sock file

### 1.0 - July, 2007

* initial release


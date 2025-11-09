# run-anywhere.sh
Bash script which lets you run any commands on multiple servers remotely.

First you need to map your ip adress to the server name by doing: echo '[ip-adress server-name]' >> /etc/hosts

Then you do: ssh-keygen Press: 'Enter' a few times Then do: ssh-copy-id [server-name] Then write: 'yes' and press 'Enter'

Now you can start executing commands

But if you want to use another file for the server names then you can create a file with what ever server names you want and use the '-f' option

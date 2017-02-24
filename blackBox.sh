##This Script will Log all the activities performed by any user from the time of login.
##Place an entry for this script in  /etc/profile so that it executes for every user.

#ALIASES to be used
time=$(date +%Y-%m-%d-%H-%M-%S)                                 #The format of date & time will be like this 2016-07-12-22-45
term=$(tty |cut -c10-)                                          # Pseudo terminal name 
ip=$(w |grep pts/$term |awk '{print $3}')                       # IP of the user

dir=/BlackBox                                           #A folder BlackBox which is used to save log files
cLog=$dir/command.log-$(whoami)-pts${term}-${ip}-${time}        #Log file for the commands 
tLog=$dir/time.log-$(whoami)-pts${term}-${ip}-${time}           # Log file for the time

#COMMANDS to be executed
/usr/bin/script -q $cLog --timing=$tLog                         #Script command is executed to start logging 
chattr +i $cLog                                                 # Locking both log files to prevent users from deletion / modification
chattr +i $tLog                                                 

##NOTE: Don't forget to create BlackBox directory in /var/log/ or script won't work, 
##To avoid permission issues place in /home/ or any other directory which is accessible for all users.

if [ $(whoami) = root ]
	then		ses=$(ps -eaf |grep pts/$term |grep -v grep |grep 'sudo -i' | awk '{print $2}')
				kill -9 $ses
	else        ses=$(ps -eaf |grep pts/$term |grep -v grep |grep sshd | awk '{print $2}')
				kill -9 $ses
fi

#===========================================END=OF=SCRIPT==============================================================================
# Copy the above lines in this file
vim /home/BlackBox.sh ; chmod 707 /home/BlackBox.sh

#create directory for logs

mkdir /BlackBox ; chmod 707 /BlackBox
chmod u+s /usr/bin/chattr 
#make script to execute on login 
echo "/home/BlackBox.sh" >> /etc/profile

chmod u+s /usr/bin/script



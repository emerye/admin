#/bin/bash

FILEPATH=/home/andy/src/scripts/setup/files

cp -f $FILEPATH/hosts.allow /etc  
cp -f $FILEPATH/hosts.deny /etc 
cp -f $FILEPATH/ntp.conf /etc 
cp -f $FILEPATH/sendmail.mc /etc/mail
cp -f $FILEPATH/access /etc/mail
make /etc/mail/Makefile
/sbin/service sendmail restart

echo "172.16.20.5   sv1.r2.local   sv1"  >> /etc/hosts

/sbin/chkconfig ntpd on 
/sbin/service ntpd start

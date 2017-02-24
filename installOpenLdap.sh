# This script will install and configure 
# openLDAP and phpLDAPadmin using below
# given CREDENTIALS 
# Domain Name: ldap.domain.com
# Username: admin
# passwd: ldaptesting
# phpldapadmin url: ldap.domain.com/phpldapadmin
# php console username: cn=admin,dc=ldap,dc=domain,dc=com
# simply follow the method or copy  paste the commands into
# the server and you are ready to rock :) :) :) 


#================================#
#    Installing OpenLDAP Server  #
#================================#

# Install the following packages 
yum -y install openldap openldap-clients openldap-servers



#Set password for admin user 
slappasswd -s ldaptesting > passwdLdap
echo olcRootPW: $(cat passwdLdap) >> /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif  



# Replace the following  lines with your domain name in olcDatabase\=\{2\}bdb.ldif
# OLD Value:- olcSuffix: dc=my-domain,dc=com		#NEW Value:- olcSuffix: dc=ldap,dc=domain,dc=com          
sed -i 's/olcSuffix: dc=my-domain,dc=com/olcSuffix: dc=ldap,dc=domain,dc=com/' /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif  



# Change the following entries with your domain in /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif  
#OLD Value:- olcRootDN: cn=Manager,dc=my-domain,dc=com  #NEW Value:- olcRootDN: cn=admin,dc=ldap,dc=domain,dc=com
sed -i 's/olcRootDN: cn=Manager,dc=my-domain,dc=com/olcRootDN: cn=admin,dc=ldap,dc=domain,dc=com/' /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif  



# Change the following entries with your domain in olcDatabase\=\{1\}monitor.ldif 
# OLD Value:- cn=Manager,dc=my-domain,dc=com		#NEW Value:- cn=admin,dc=ldap,dc=domain,dc=com
sed -i  's/cn=manager,dc=my-domain,dc=com/cn=admin,dc=ldap,dc=domain,dc=com/' /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{1\}monitor.ldif 



# Give ownership to ldap user for the following files to avoid permission issues
chown ldap.ldap  /etc/openldap/slapd.d/cn\=config/*



# Make sure service starts at boot time
chkconfig slapd on



# Start LDAP Server
service slapd start
cp /usr/share/doc/sudo-1.8.6p3/schema.OpenLDAP /etc/openldap/schema/sudo.schema

#================================#
#    Installing phpLDAP Admin    #
#================================#

# Install pacakge from Yum Repo
yum install phpldapadmin -y 



#Comment Line 397 and and Uncomment Line 398
sed -i '397s%// %%' /etc/phpldapadmin/config.php 
sed -i '398s%^%//%' /etc/phpldapadmin/config.php 



#Allow GUI access to Private Network
sed -i 's@ Allow from 127.0.0.1@ Allow from 127.0.0.1 192.168.100.0/24@' /etc/httpd/conf.d/phpldapadmin.conf



#Start Apache Server 
service httpd start
ip=$(ifconfig |grep inet |grep cast| awk '{print $2}' | awk -F ":" '{print $2}')
clear
printf  "LDAP Installed successfully you can access it with this URL \n\n$ip/phpldapadmin\n\n" 


#### SCRIPT FINISHES HERE #### #### SCRIPT FINISHES HERE #### #### SCRIPT FINISHES HERE #### #### SCRIPT FINISHES HERE #### #### SCRIPT FINISHES HERE ####

#================================#
#  Configuring OpenLDAP CLIENT   #
#================================#

#Run these commands on client side 
#so that it can authenticate with 
#LDAP Server 

# Install required packages 
yum install nss-pam-ldapd openldap-clients -y


# enable ldap authentication using the given comand
authconfig --enableldap --ldapserver=192.168.100.101  --ldapbasedn="dc=ldap,dc=domain,dc=com" --enablemkhomedir --update

yum install python27-devel   python27-pip  openldap-devel gcc -y
pip-2.7 install ssh-ldap-pubkey
cp /usr/local/bin/ssh-ldap-pubkey* /usr/bin/
sed -i  's@/etc/ldap.conf@/etc/openldap/ldap.conf@' /usr/bin/ssh-ldap-pubkey
sed -i 's@#AuthorizedKeysCommand none@AuthorizedKeysCommand /usr/bin/ssh-ldap-pubkey-wrapper@' /etc/ssh/sshd_config
sed -i 's@#AuthorizedKeysCommandUser nobody@AuthorizedKeysCommandUser nobody@' /etc/ssh/sshd_config
echo "sudoers:  ldap" >> /etc/nsswitch.conf
echo "sudoers_base ou=SUDOers,dc=ldap,dc=domain,dc=com" >> /etc/sudo-ldap.conf 
echo "URI ldap://192.168.100.101/" >> /etc/sudo-ldap.conf 
service sshd restart
#======================================================#
# Note: Don't forget to enable 389 traffic in firewall #
#======================================================#

###############################################################################################################################################

scp -r root@192.168.100.101:/tmp/openLDAP/ /tmp/openLDAP

ldapadd  -Y EXTERNAL 	  -H ldapi:///  	-f /tmp/openLDAP/sshSchema.ldif 
ldapadd  -Y EXTERNAL 	  -H ldapi:///      -f /tmp/openLDAP/sudoSchema.ldif 

ldapadd -x -w ldaptesting -H ldapi:/// -D "cn=admin,dc=ldap,dc=domain,dc=com" -f /tmp/openLDAP/structure.ldif
ldapadd -x -w ldaptesting -H ldapi:/// -D "cn=admin,dc=ldap,dc=domain,dc=com" -f /tmp/openLDAP/groups.ldif 
ldapadd -x -w ldaptesting -H ldapi:/// -D "cn=admin,dc=ldap,dc=domain,dc=com" -f /tmp/openLDAP/users.ldif 
ldapadd -x -w ldaptesting -H ldapi:/// -D "cn=admin,dc=ldap,dc=domain,dc=com" -f /tmp/openLDAP/sudoers.ldif 

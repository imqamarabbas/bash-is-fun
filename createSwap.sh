# Create an empty directory 
mkdir /swap ; cd /swap

# Create a blank file of the required size (16GB in this case)
fallocate -l 16G swapFile


# To prevent the file from being world-readable, you should set up the correct permissions on the swap file:
chown root:root /swap/swapFile
chmod 0600 /swap/swapFile


mkswap swapFile				#Convert the blank file into swap 


swapon swapFile ; free -m	#Enable swap and check the status

# Add an entry in fstab to enable it on startup.
cat /etc/fstab
echo "/swap/swapFile          swap            swap    defaults        0 0" >> /etc/fstab
cat /etc/fstab

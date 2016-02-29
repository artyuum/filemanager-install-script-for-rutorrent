#!/bin/bash
# Link: https://github.com/ArtyumX/Filemanager-install-script-for-ruTorrent
# --------------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# * <ArtyumX> wrote this file. As long as you retain this notice you
# * can do whatever you want with this stuff. If we meet some day, and you think
# * this stuff is worth it, you can buy me a beer in return Poul-Henning Kamp
# --------------------------------------------------------------------------------
clear


# Checking if user is root
if [ "$(id -u)" != "0" ]; then
	echo
	echo "Sorry, this script must be run as root." 1>&2
	echo
	exit 1
fi


# Asking for the ruTorrent path folder
read -p "Please type your ruTorrent path folder: " -e -i /var/www/rutorrent rutorrent_path
read -p "Please type your rTorrent downloads path folder (exemple: /home/user/Downloads): " -e rtorrent_downloads


# Installing dependencies
apt-get -y install subversion
apt-get install zip

cd /tmp

if [ `getconf LONG_BIT` = "64" ]
then
    wget http://www.rarlab.com/rar/rarlinux-x64-5.3.0.tar.gz
    tar -xzvf rarlinux-x64-5.3.0.tar.gz
    rm rarlinux-x64-5.3.0.tar.gz
else
    wget http://www.rarlab.com/rar/rarlinux-5.3.0.tar.gz
    tar -xzvf rarlinux-5.3.0.tar.gz
    rm rarlinux-5.3.0.tar.gz
fi

mv -v rar/rar_static /usr/local/bin/rar
chmod 755 /usr/local/bin/rar


# Installing and configuring filemanager plugin
cd $rutorrent_path/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager/

cat > $rutorrent_path/plugins/filemanager/conf.php << EOF
<?php

\$fm['tempdir'] = '/tmp';                // path were to store temporary data ; must be writable
\$fm['mkdperm'] = 755;           // default permission to set to new created directories

// set with fullpath to binary or leave empty
\$pathToExternals['rar'] = '/usr/local/bin/rar';
\$pathToExternals['zip'] = '/usr/bin/zip';
\$pathToExternals['unzip'] = '/usr/bin/unzip';
\$pathToExternals['tar'] = '/bin/tar';

// archive mangling, see archiver man page before editing

\$fm['archive']['types'] = array('rar', 'zip', 'tar', 'gzip', 'bzip2');

\$fm['archive']['compress'][0] = range(0, 5);
\$fm['archive']['compress'][1] = array('-0', '-1', '-9');
\$fm['archive']['compress'][2] = \$fm['archive']['compress'][3] = \$fm['archive']['compress'][4] = array(0);

?>
EOF

# Configuring ruTorrent config.php file
sed -i "s|$topDirectory = '/';|$topDirectory = '${rtorrent_downloads}';|g" $rutorrent_path/conf/config.php


# Permissions for filemanager
chown -R www-data:www-data $rutorrent_path/plugins/filemanager
chmod -R 775 $rutorrent_path/plugins/filemanager/scripts


# End of the script
echo
echo
echo -e "\033[0;32;148mInstallation done.\033[39m"

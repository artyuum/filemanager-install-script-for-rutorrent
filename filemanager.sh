#!/bin/bash
# Link: https://github.com/ArtyumX/Filemanager-install-script-for-ruTorrent
# --------------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# * <artyum@lolwallpapers.net> wrote this file. As long as you retain this notice you
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


# Installing dependencies
apt-get install subversion zip

cd /tmp

if [ `getconf LONG_BIT` = "64" ]
then
    wget -O rarlinux-x64.tar.gz http://www.rarlab.com/rar/rarlinux-x64-5.4.0.tar.gz
    tar -xzvf rarlinux-x64.tar.gz
    rm rarlinux-x64.tar.gz
else
    wget -O rarlinux.tar.gz http://www.rarlab.com/rar/rarlinux-5.4.0.tar.gz
    tar -xzvf rarlinux.tar.gz
    rm rarlinux.tar.gz
fi

mv -v rar/rar_static /usr/local/bin/rar
chmod 755 /usr/local/bin/rar


# Installing and configuring filemanager plugin
cd $rutorrent_path/plugins/
svn co https://github.com/nelu/rutorrent-thirdparty-plugins/trunk/filemanager

cat > $rutorrent_path/plugins/filemanager/conf.php << EOF
<?php

\$fm['tempdir'] = '/tmp';                // path were to store temporary data ; must be writable
\$fm['mkdperm'] = 755;           // default permission to set to new created directories

// set with fullpath to binary or leave empty
\$pathToExternals['rar'] = '$(which rar)';
\$pathToExternals['zip'] = '$(which zip)';
\$pathToExternals['unzip'] = '$(which unzip)';
\$pathToExternals['tar'] = '$(which tar)';

// archive mangling, see archiver man page before editing

\$fm['archive']['types'] = array('rar', 'zip', 'tar', 'gzip', 'bzip2');

\$fm['archive']['compress'][0] = range(0, 5);
\$fm['archive']['compress'][1] = array('-0', '-1', '-9');
\$fm['archive']['compress'][2] = \$fm['archive']['compress'][3] = \$fm['archive']['compress'][4] = array(0);

?>
EOF


# Permissions for filemanager
chown -R www-data:www-data $rutorrent_path/plugins/filemanager
chmod -R 775 $rutorrent_path/plugins/filemanager/scripts


# End of the script
clear
echo
echo
echo -e "\033[0;32;148mInstallation done.\033[39m"

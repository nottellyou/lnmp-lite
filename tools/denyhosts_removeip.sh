#!/bin/bash
# Author:hdwo.net
# Website:http://hdwo.net

HOST=$1
if [ -z "${HOST}" ]; then
    echo "Usage:$0 IP"
    exit 1
fi

echo "Remove IP:${HOST} from denyhosts..."
/etc/init.d/denyhosts stop
echo '
/etc/hosts.deny
/usr/share/denyhosts/data/hosts
/usr/share/denyhosts/data/hosts-restricted
/usr/share/denyhosts/data/hosts-root
/usr/share/denyhosts/data/hosts-valid
/usr/share/denyhosts/data/users-hosts
' | grep -v "^$" | xargs sed -i "/${HOST}/d"
echo " done"
/etc/init.d/denyhosts start
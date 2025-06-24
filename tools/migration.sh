#!/usr/bin/env bash

BASE_PATH=
USER_SHELL=/bin/bash

while [ -n "$1" ] ; do
    case $1 in
        -u | --user )
            shift
            USERNAME=$1
        ;;
        -t | --target )
            shift
            TARGET=$1
        ;;
        -d | --destination )
            shift
            DESTINATION=$1
        ;;
        * )
            echo "ERROR: Unknown option: $1"
            exit -1
        ;;
    esac
    shift
done

echo "Dump MySQL Database"
sleep 1s
sudo mysqldump -u root $USERNAME > "/home/$USERNAME/$USERNAME.sql"

echo "Compressed Home Directory"
sleep 1s
sudo zip -r "/home/$USERNAME.zip" "/home/$USERNAME"

echo "Transfer to Destination Server"
sleep 1s
sudo rsync -avz --progress --rsh="ssh -p22 -i /root/.ssh/id_rsa" "/home/$USERNAME.zip" "$DESTINATION:/home/$TARGET"

echo "Remove Temporary file"
sleep 1s
sudo unlink "/home/$USERNAME/$USERNAME.sql"
sudo unlink "/home/$USERNAME.zip"

echo "Migration complete"
exit 1;
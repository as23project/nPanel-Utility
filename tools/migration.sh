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

sudo cd "/home/$USERNAME"
sudo mysqldump -u root $USERNAME > "$USERNAME.sql"
sudo zip -r "$USERNAME.zip" "$USERNAME.sql web"
sudo rsync -avz --progress --rsh="ssh -p22 -i /root/.ssh/id_rsa" "$USERNAME.zip" "$DESTINATION:/home/$TARGET"
sudo unlink "$USERNAME.sql"
sudo unlink "$USERNAME.zip"
echo "Migration complete"
exit 1;
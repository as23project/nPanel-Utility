#!/bin/bash

GITHUB="BuyProject/nPanel"
BRANCH="latest"

SSH_KEY="/etc/npanel/github"
WORK_TREE="/var/www/html"
GIT_DIR="/var/www/git/deploy.git"
chmod 600 $SSH_KEY
eval $(ssh-agent -s)
ssh-add $SSH_KEY
REPO="git@github.com:$GITHUB"

if [ -d "$GIT_DIR" ]; then
cd $WORK_TREE
sudo git init --bare $GIT_DIR
sudo git --work-tree=$WORK_TREE --git-dir=$GIT_DIR fetch
sudo git --work-tree=$WORK_TREE --git-dir=$GIT_DIR fetch origin --tags --force
sudo git --work-tree=$WORK_TREE --git-dir=$GIT_DIR checkout -f $BRANCH
sudo git --work-tree=$WORK_TREE --git-dir=$GIT_DIR merge origin/$BRANCH
else
sudo  git init --bare $GIT_DIR
sudo  rm -rf $WORK_TREE
sudo  mkdir $WORK_TREE
sudo  git --work-tree=$WORK_TREE --git-dir=$GIT_DIR remote add origin $REPO
sudo  git --work-tree=$WORK_TREE --git-dir=$GIT_DIR fetch
sudo  git --work-tree=$WORK_TREE --git-dir=$GIT_DIR fetch origin --tags --force
sudo  git --work-tree=$WORK_TREE --git-dir=$GIT_DIR checkout -f $BRANCH
sudo  git --work-tree=$WORK_TREE --git-dir=$GIT_DIR merge origin/$BRANCH
fi

# cd /var/www/html && git config --global --add safe.directory /var/www/html
# cd /var/www/html && git stash
# cd /var/www/html && git fetch
# cd /var/www/html && git pull

sudo chmod -R o+w /var/www/html/storage
sudo chmod -R 775 /var/www/html/storage
sudo chmod -R o+w /var/www/html/bootstrap/cache
sudo chmod -R 775 /var/www/html/bootstrap/cache
sudo chown -R www-data:npanel /var/www/html
sudo chmod -R 750 /var/www/html

# cd /var/www/html && composer update --no-interaction
# cd /var/www/html && php artisan cache:clear
# cd /var/www/html && php artisan view:cache
# cd /var/www/html && php artisan config:cache
# cd /var/www/html && php artisan migrate --force

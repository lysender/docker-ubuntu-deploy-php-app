#!/bin/bash

__run_clone() {
    # Initialize ssh known hosts
    touch /root/.ssh/known_hosts
    ssh-keyscan $APP_GIT_REPO_HOST >> /root/.ssh/known_hosts

    # Remove all contents first
    rm -rf /var/www/html/*

    # Clone repo
    git clone $APP_GIT_REPO /var/www/html
    cd /var/www/html
    git checkout $APP_GIT_BRANCH
}

__run_pull() {
    # Update
    cd /var/www/html && git pull origin $APP_GIT_BRANCH
}

if [ -d /var/www/html/.git ]
then
    __run_pull
else
    __run_clone
fi


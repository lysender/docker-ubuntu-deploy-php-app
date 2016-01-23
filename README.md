# Deploy and auto-update PHP based apps

Deploys the PHP app via git. Container starts, execute deployment, then exit.

Deployment is triggered via cron or any scheduler tool from your host or cloud infra.

For first run, it clones the repo.

For succeding runs, it pulls from the master branch at certain interval.

## Overview

The purpoe of this container is to automate your php app's deployment via GIT. This assumes that you already have dockerized PHP app and perhaps the source code is just mounted from the host machine (which I did before).

In order to partially or fully automate the process, we put the PHP app's source code inside a volumne container and perform the GIT operation via a deploy container. Therefore, we need the following:

* Your dockerized PHP app
* A deploy container which handles the automatic git pull
* A volumne container which contains the source code and other data shared by both PHP app and the deploy container

This setup assumes the following:

* PHP app's source code is at `/var/www/html`
* PHP app's logs located at `/var/log/apache2`
* You already generated a custom ssh key as deployment key (supported by bitbucket and github)
  * The deployment SSH key files are at:
      * /path/to/deploy-keys/php-app-keys/id_rsa
      * /path/to/deploy-keys/php-app-keys/id_rsa.pub
  * We need to mount the deployment key directory into container's `/root/.ssh` dir
* That you would provide the following ENV vars upon container creation
  * `APP_GIT_REPO` - clone url
  * `APP_GIT_BRANCH` - ex: master
  * `APP_GIT_REPO_HOST` - ex: github.com

## Volumne container for php codes and the deployment keys

In order for this deploy agent to work, we must create a volume container and share it with the PHP app container and this deploy container.

    docker create --name php-app-data \
        -v /path/to/deploy-keys/php-app-keys:/root/.ssh \
        -v /var/log/apache2 \
        -v /var/www/html \
        my-php-app-image /bin/true

Then, delete your existing PHP app's container and re-run but at this time, use the volumes-from parameter.

    # Stop, delete including volumnes
    docker stop php-app && docker rm -v php-app
    
    # Re-create the container
    docker run --name php-app --volumnes-from php-app-data ... other docker parameters

Next, let's build the deploy agent image from source (or skip and simply re-use my publicly hosted image).

## Build from source

    cd /path/to/source
    docker build --rm -t lysender/deploy-php-app-cron .

## Running the container

Note: You can build your own image or re-use my existing image.

    docker run \
        --name deploy-agent \
        -d \
        --volumes-from php-app-data \
        -e "APP_GIT_REPO=git@bitbucket.org:me/blog.git" \
        -e "APP_GIT_BRANCH=master" \
        -e "APP_GIT_REPO_HOST=bitbucket.org" \
        lysender/deploy-php-app-cron

## Verify

Check if the deployment succeed.

    docker logs deploy-agent

You should see some git related messages and you should be able to figure out if it fails or not.

## Schedule the task

For cron example, we can schedule to run the deployment container every 10 minutes for example (user based cron as an example).

0,10,20,30,40,50 * * * * docker run deploy-agent


FROM lysender/ubuntu-php
MAINTAINER Leonel Baer <leonel@lysender.com>

RUN apt-get -y install pwgen && apt-get clean

# Configure servicies
ADD ./deploy.sh /deploy.sh
RUN chmod 0775 /deploy.sh
RUN mkdir -p /var/log/deploy-agent

VOLUME ["/var/www/html", "/root/.ssh", "/var/log/deploy-agent"]

CMD ["/bin/bash", "/deploy.sh"]


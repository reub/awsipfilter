FROM nginx:latest
MAINTAINER reub@panix.com

# Install nodejs, cron, supervisor and cleanup apt temp files
RUN \
  apt-get update -y && \
  apt-get install -y nodejs && \
  apt-get install -y npm && \
  apt-get install -y cron && \
  apt-get install -y supervisor && \
  rm -rf /var/lib/apt/lists/* 

# Add the supervisord.conf file
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add the proxy.conf and remove the default.conf
ADD proxy.conf /etc/nginx/conf.d/proxy.conf
RUN rm -f /etc/nginx/conf.d/default.conf

# Add the node.js script that pulls down the AWS outbound ip-list and updates the nginx conf file
RUN mkdir -p /usr/local/bin/whitelist/
ADD app.js /usr/local/bin/whitelist/app.js

# Add the script that will reload the ip whitelist and restart the nginx process, set appropriate file permissions
ADD reload.sh /usr/local/bin/whitelist/reload.sh
ADD start.sh /uar/local/bin/whitelist/start.sh
RUN chmod 700 /usr/local/bin/whitelist/reload.sh /uar/local/bin/whitelist/start.sh /usr/local/bin/whitelist/app.js

# Add the crontab that will run the above script hourly, set the permissions and start the cron daemon
RUN mkdir -p /etc/cron.d/ && touch /var/log/cron.log
ADD crontab /etc/cron.d/reload-cron
RUN chmod 0644 /etc/cron.d/reload-cron

# Redirect the cron output in case we want to check the whitelist reload output
RUN ln -sf /dev/stdout /var/log/cron.log

# Debugging...
#ADD dummy-index.html /usr/share/nginx/html/index.html

#CMD ["/usr/bin/supervisord"]
CMD ["/uar/local/bin/whitelist/start.sh"]

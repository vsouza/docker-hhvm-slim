FROM phusion/baseimage:0.9.13

# Set correct environment variables.
ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install add-apt-repository
RUN sudo apt-get update
RUN sudo apt-get install -y unzip software-properties-common python-software-properties git curl vim

# we'll need wget to fetch the key...
RUN sudo apt-get install -y wget

# install hhvm
RUN wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list
RUN sudo apt-get update
RUN sudo apt-get install -y hhvm

# install nginx
RUN sudo apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# configure ngnix
RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run
RUN chmod 700 /etc/service/nginx/run

# configure hhvm
RUN mkdir /etc/service/hhvm
ADD hhvm.sh /etc/service/hhvm/run
RUN chmod 700 /etc/service/hhvm/run

# set up nginx default site
ADD default /etc/nginx/sites-available/default

RUN mkdir /var/www/public

# Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

ADD .hhconfig /var/www/public/.hhconfig
ADD index.hh /var/www/public/index.hh

RUN sudo /usr/share/hhvm/install_fastcgi.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose port 80
EXPOSE 80

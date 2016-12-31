FROM phusion/baseimage:0.9.19
MAINTAINER  Christian Prior "cprior@gmail.com"

RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN /usr/sbin/enable_insecure_key

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get install locales iputils-ping
#http://stackoverflow.com/a/40235306
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_DK.UTF-8; export LANG=en_DK.UTF-8; export LC_ALL=en_DK.UTF-8; locale-gen en_DK.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

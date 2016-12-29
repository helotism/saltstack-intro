FROM phusion/baseimage:0.9.19
MAINTAINER  Christian Prior "cprior@gmail.com"

RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN /usr/sbin/enable_insecure_key

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get install locales
#http://stackoverflow.com/a/40235306
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_DK.UTF-8; export LANG=en_DK.UTF-8; export LC_ALL=en_DK.UTF-8; locale-gen en_DK.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# ...put your own build instructions here...
RUN curl -L https://bootstrap.saltstack.com | sh -s -- -M -L -A saltmaster -i saltminion -X git v2016.11.1


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN mkdir /etc/service/saltmaster
ADD assets/phusion-baseimage/saltmaster.sh /etc/service/saltmaster/run
RUN mkdir /etc/service/saltminion
ADD assets/phusion-baseimage/saltminion.sh /etc/service/saltminion/run


EXPOSE 4505
EXPOSE 4506

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

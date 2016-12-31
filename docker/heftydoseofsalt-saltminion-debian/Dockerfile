FROM debian:jessie
MAINTAINER  Christian Prior "cprior@gmail.com"

# ...put your own build instructions here...
RUN curl -L https://bootstrap.saltstack.com | sh -s -- -L -A saltmaster -X git v2016.11.1

#RUN mkdir /etc/service/saltmaster
#ADD docker/assets/phusion-baseimage/saltmaster.sh /etc/service/saltmaster/run
#RUN mkdir /etc/service/saltminion
#ADD docker/assets/phusion-baseimage/saltminion.sh /etc/service/saltminion/run


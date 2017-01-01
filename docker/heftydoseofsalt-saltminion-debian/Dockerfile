FROM debian:jessie
MAINTAINER  Christian Prior "cprior@gmail.com"

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y locales apt-utils \
        supervisor \
        curl \
    && DEBIAN_FRONTEND=noninteractive localedef -i en_DK -c -f UTF-8 -A /usr/share/locale/locale.alias en_DK.UTF-8
#http://stackoverflow.com/a/40235306
#ENV TZ=Europe/Berlin
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN dpkg-reconfigure -f noninteractive tzdata
#RUN export LANGUAGE=en_DK.UTF-8; export LANG=en_DK.UTF-8; export LC_ALL=en_DK.UTF-8; \
#    locale-gen en_DK.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN apt-get update && apt-get install -y openssh-server apache2 supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

# ...put your own build instructions here...
#RUN apt-get install -y curl
RUN curl -L https://bootstrap.saltstack.com | sh -s -- -L -A saltmaster -X git v2016.11.1

#https://docs.docker.com/engine/admin/using_supervisord/
COPY heftydoseofsalt-saltminion-debian/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

CMD ["/usr/bin/supervisord"]
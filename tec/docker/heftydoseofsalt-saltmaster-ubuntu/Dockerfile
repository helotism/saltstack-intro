FROM helotism/heftydoseofsalt-minimal-ubuntu:latest
MAINTAINER  Christian Prior "cprior@gmail.com"

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
#https://www.linkedin.com/pulse/saltstacks-gitfs-ubuntu-denis-kalinin
RUN apt-get install -y cmake python-pip wget pkg-config openssl libssl-dev libssl1.0.0 libhttp-parser-dev libssh2-1-dev apt-utils
RUN pip install --upgrade pip && pip install pyyaml
#http://www.pygit2.org/install.html
RUN wget --quiet https://github.com/libgit2/libgit2/archive/v0.25.0.tar.gz --directory-prefix /tmp
RUN cd /tmp && tar xzf ./v0.25.0.tar.gz
RUN cd /tmp/libgit2-0.25.0 && cmake . && make && make install && ldconfig
RUN pip install cffi && pip install pygit2
RUN cd

# -M master -L cloud -P pip-based
RUN curl -L https://bootstrap.saltstack.com | sh -s -- -P -M -L -A saltmaster -J '{"gitfs_provider":"pygit2","fileserver_backend":["roots","git"],"file_roots":{"base":["/srv/salt", "/srv/formulas/users_formula"]},"gitfs_remotes": [{"https://github.com/cprior/saltstack-not-yet-formulas.git": [{"root": "application/physical/saltstack/srv/salt"}, {"base": "master"}]}]}' -i minion-on-saltmaster -X git v2016.11.1

RUN mkdir /etc/service/saltmaster
ADD assets/phusion-baseimage/saltmaster.sh /etc/service/saltmaster/run
RUN mkdir /etc/service/saltminion
ADD assets/phusion-baseimage/saltminion.sh /etc/service/saltminion/run

EXPOSE 4505
EXPOSE 4506
EXPOSE 8888

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

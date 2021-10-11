FROM ubuntu:latest
LABEL maintainer='ParFlesh'

ENV LANG=C.UTF-8 \
    TZ=Etc/UTC \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates software-properties-common && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    add-apt-repository -y ppa:jcfp/sab-addons && \
    add-apt-repository -y ppa:jcfp/nobetas && \
    apt-get -q update &&\
    apt-get install -y sabnzbdplus && \
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /tmp/* && \
    mkdir -p /config /media && \
    chown 1001:0 /config /media && \
    chmod 770 /config /media

ADD test.sh /
VOLUME ["/config", "/media"]
EXPOSE 8080
WORKDIR /config
ENTRYPOINT ["/usr/bin/sabnzbdplus"]
CMD ["-b", "0", "-f", "/config/config.ini", "-s", "0.0.0.0:8080", "--disable-file-log"]

FROM ubuntu:latest as artifact

ARG SABNZBD_VERSION="latest"

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update &&\
    apt-get install -y curl &&\
    if [ "latest" != "$SABNZBD_VERSION" ]; then VERSION=$SABNZBD_VERSION ; else VERSION=$(curl https://github.com/sabnzbd/sabnzbd/releases/latest 2>/dev/null | awk -F'"' '{print $2}' | awk -F'/' '{print $NF}');fi && \
    curl -SL https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz | tar zxvf - &&\
    mv SABnzbd-* /sabnzbd &&\
    chown -R 1001:0 /sabnzbd &&\
    chmod -R g=u /sabnzbd

ADD test.sh /sabnzbd/

RUN chmod 755 /sabnzbd/test.sh && \
    chown 1001:0 /sabnzbd/test.sh

FROM ubuntu:latest
LABEL maintainer='ParFlesh'

COPY --chown=1001:0 --from=artifact /sabnzbd /sabnzbd

ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive &&\
    sed -i "s#deb http://deb.debian.org/debian buster main#deb http://deb.debian.org/debian buster main non-free#g" /etc/apt/sources.list &&\
    apt-get -q update &&\
    apt-get install --no-install-recommends -qqy build-essential python3 python3-cheetah python3-setuptools python3-pip libffi-dev libssl-dev python3-dev python3-cryptography python3-pip par2 unrar p7zip-full unzip openssl python3-openssl ca-certificates &&\
    pip3 install sabyenc feedparser configobj cheroot cherrypy portend chardet notify2 puremagic guessit && \
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /tmp/* && \
    mkdir -p /config /media && \
    chown 1001:0 /config /media && \
    chmod 770 /config /media

ADD test.sh /
VOLUME ["/config", "/media"]
EXPOSE 8080
WORKDIR /sabnzbd
ENTRYPOINT ["/sabnzbd/SABnzbd.py"]
CMD ["-b", "0", "-f", "/config/config.ini", "-s", "0.0.0.0:8080", "--disable-file-log"]

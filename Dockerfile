FROM ubuntu:rolling as artifact

ARG SABNZBD_VERSION=""

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q update &&\
    apt-get install -qqy curl &&\
    if [ "latest" != "$SABNZBD_VERSION" ]; then VERSION=$SABNZBD_VERSION ; else VERSION=$(curl https://github.com/sabnzbd/sabnzbd/releases/latest 2>/dev/null | awk -F'"' '{print $2}' | awk -F'/' '{print $NF}');fi && \
    curl -SL https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz | tar zxvf - &&\
    mv SABnzbd-* /sabnzbd &&\
    chown -R 1001:0 /sabnzbd &&\
    chmod -R g=u /sabnzbd && \
    curl https://bootstrap.pypa.io/get-pip.py --output /get-pip.py

ADD test.sh /sabnzbd/

RUN chmod 755 /sabnzbd/test.sh && \
    chown 1001:0 /sabnzbd/test.sh

FROM ubuntu:rolling
MAINTAINER ParFlesh

COPY --chown=1001:0 --from=artifact /sabnzbd /sabnzbd
COPY --chown=1001:0 --from=artifact /get-pip.py /get-pip.py

ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive &&\
    sed -i "s#deb http://deb.debian.org/debian buster main#deb http://deb.debian.org/debian buster main non-free#g" /etc/apt/sources.list &&\
    apt-get -q update &&\
    apt-get install --no-install-recommends -qqy python python-cheetah python-cryptography par2 unrar p7zip-full unzip openssl python-openssl ca-certificates &&\
    python /get-pip.py && \
    pip install sabyenc && \
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

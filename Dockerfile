FROM debian:stable-slim

ENV HOME /zcash

ENV USER_ID 1000
ENV GROUP_ID 1000
ENV ZEC_VERSION=2.0.2

RUN groupadd -g ${GROUP_ID} zcash \
  && useradd -u ${USER_ID} -g zcash -s /bin/bash -m -d /zcash zcash \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  build-essential pkg-config libc6-dev m4 g++-multilib \
  autoconf libtool ncurses-dev unzip git python python-zmq \
  zlib1g-dev wget curl bsdmainutils automake \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://z.cash/downloads/zcash-$ZEC_VERSION-linux64.tar.gz | tar xz --strip=2 -C /usr/local/bin

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/zec_oneshot

VOLUME ["/zcash"]

EXPOSE 8232
EXPOSE 8233

WORKDIR /zcash

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["zec_oneshot"]
FROM bitsler/wallet-base:focal

ENV HOME /zcash

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN groupadd -g ${GROUP_ID} zcash \
  && useradd -u ${USER_ID} -g zcash -s /bin/bash -m -d /zcash zcash \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG version=2.1.2-3
ENV ZEC_VERSION=$version

RUN curl -sL https://z.cash/downloads/zcash-$ZEC_VERSION-linux64-debian-stretch.tar.gz | tar xz --strip=2 -C /usr/local/bin

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/zec_oneshot

VOLUME ["/zcash"]

EXPOSE 8232 8233

WORKDIR /zcash

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["zec_oneshot"]

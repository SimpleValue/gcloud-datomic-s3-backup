FROM ubuntu:20.04

ARG DATOMIC_VERSION="0.9.6014"
ARG DATOMIC_CREDENTIALS

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg2 curl unzip openjdk-8-jre-headless tmux python3 python3-crcmod

# python3-crcmod is important to make the [crc
# checks](https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod)
# of `gsutil rsync` fast.

RUN cp /usr/bin/python3 /usr/bin/python
ENV PATH "$PATH:/gsutil"

# Downloads Datomic PRO and creates the /backup folder (mount point for gcsfuse)
RUN mkdir -p /backup && \
    curl -u "$DATOMIC_CREDENTIALS" -SL https://my.datomic.com/repo/com/datomic/datomic-pro/$DATOMIC_VERSION/datomic-pro-$DATOMIC_VERSION.zip -o /tmp/datomic.zip && \
    (cd /tmp && unzip /tmp/datomic.zip) && \
    mv /tmp/datomic-pro-$DATOMIC_VERSION /datomic

# Installs [Cloud SQL proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
RUN curl https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o cloud_sql_proxy && \
    chmod +x cloud_sql_proxy

RUN curl -o gsutil.tar.gz "https://storage.googleapis.com/pub/gsutil.tar.gz" && \
    tar xfz gsutil.tar.gz

ADD extra-libs/* /datomic/lib/

ADD boto /root/.boto

ADD backup.sh /backup.sh

ENTRYPOINT ["/backup.sh"]
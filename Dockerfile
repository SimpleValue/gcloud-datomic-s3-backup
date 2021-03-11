FROM ubuntu:20.04

ARG DATOMIC_VERSION="0.9.6014"
ARG DATOMIC_CREDENTIALS

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg2 curl unzip openjdk-8-jre-headless tmux

# Downloads Datomic PRO and creates the /backup folder (mount point for gcsfuse)
RUN mkdir -p /backup && \
    curl -u "$DATOMIC_CREDENTIALS" -SL https://my.datomic.com/repo/com/datomic/datomic-pro/$DATOMIC_VERSION/datomic-pro-$DATOMIC_VERSION.zip -o /tmp/datomic.zip && \
    (cd /tmp && unzip /tmp/datomic.zip) && \
    mv /tmp/datomic-pro-$DATOMIC_VERSION /datomic

# Installs [Cloud SQL proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
RUN curl https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o cloud_sql_proxy && \
    chmod +x cloud_sql_proxy

ADD extra-libs/* /datomic/lib/

ADD backup.sh /backup.sh

ENTRYPOINT ["/backup.sh"]
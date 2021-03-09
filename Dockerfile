FROM ubuntu:20.04

ARG DATOMIC_VERSION="0.9.6014"
ARG DATOMIC_CREDENTIALS

# Installs [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md#ubuntu-and-debian-latest-releases)
# to mount the Google Cloud storage bucket, where the Datomic backup should be stored.
RUN apt-get update && apt-get install -y lsb-release gnupg2 curl && \
    export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y gcsfuse unzip openjdk-8-jdk

# Downloads Datomic PRO and creates the /backup folder (mount point for gcsfuse)
RUN mkdir -p /backup && \
    curl -u "$DATOMIC_CREDENTIALS" -SL https://my.datomic.com/repo/com/datomic/datomic-pro/$DATOMIC_VERSION/datomic-pro-$DATOMIC_VERSION.zip -o /tmp/datomic.zip && \
    (cd /tmp && unzip /tmp/datomic.zip) && \
    mv /tmp/datomic-pro-$DATOMIC_VERSION /datomic

# Installs [Cloud SQL proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
RUN curl https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -o cloud_sql_proxy && \
    chmod +x cloud_sql_proxy

ADD backup.sh /backup.sh

ADD extra-libs/* /datomic/lib/

ENTRYPOINT ["/backup.sh"]
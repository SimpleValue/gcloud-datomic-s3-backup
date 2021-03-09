#!/bin/bash

set -e

# mounts the Google Cloud storage bucket, where the Datomic backup should be stored:
gcsfuse $BACKUP_BUCKET /backup

# Optionally starts Cloud SQL Proxy to access the database that is used as Datomic storage:
if [[ ! -z "$CLOUD_SQL_PROXY_INSTANCES" ]]; then
    ./cloud_sql_proxy -instances="${CLOUD_SQL_PROXY_INSTANCES}" &
fi

cd /datomic

# Starts the Datomic backup with a backupPaceMsec to avoid overloading the Datomic storage database:
bin/datomic -Xms500m -Xmx500m -Ddatomic.backupPaceMsec=5 backup-db "$DATOMIC_URI" "file:///backup"

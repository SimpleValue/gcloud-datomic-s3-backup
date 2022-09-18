#!/bin/bash

set -e

# Optionally starts Cloud SQL Proxy to access the database that is used as Datomic storage:
if [[ ! -z "$CLOUD_SQL_PROXY_INSTANCES" ]]; then
    ./cloud_sql_proxy -instances="${CLOUD_SQL_PROXY_INSTANCES}" -log_debug_stdout &
    # `-log_debug_stdout` avoids false positive error log entries in Google Cloud Logging.
fi

set -u

cd /datomic

# Starts the Datomic backup with a backupPaceMsec to avoid overloading the Datomic storage database:
bin/datomic -Xms4g -Xmx4g -Ddatomic.backupPaceMsec=5 backup-db "$DATOMIC_URI" "$S3_URI"
